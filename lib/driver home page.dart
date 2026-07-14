import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'services/place_service.dart';
import 'services/driver_tracking_service.dart';
import 'services/driver_location_service.dart';
import 'services/socket_service.dart';
import 'services/booking_service.dart';
import 'driver_navigation_page.dart';
import 'menu/menu.dart';


void main() {
  runApp(const MyApp());
}

/// ROOT
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(driverId: "preview", ambulanceType: "BLS"),
    );
  }
}

/// HOME PAGE
class HomePage extends StatefulWidget {
  /// The Supabase auth user id for this driver — set at login. Falls back
  /// to an empty string only for old call sites that haven't been updated
  /// yet; tracking/socket won't start with an empty id.
  final String driverId;

  /// Must match one of the strings the User App books with:
  /// "BLS" / "ALS" / "Bike" / "Neonatal".
  final String ambulanceType;

  const HomePage({
    super.key,
    this.driverId = "",
    this.ambulanceType = "BLS",
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // ===========================
  // STATE VARIABLES
  // ===========================

  /// The currently pending incoming booking request, or null if there's
  /// no request waiting. This — not a hardcoded flag — is what controls
  /// whether the request card shows at all.
  Map<String, dynamic>? incomingBooking;

  bool isOnline = true;
  bool isResponding = false;

  DriverTrackingService? _tracking;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  // Search
  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> searchResults = [];

  bool showSearchResults = false;

  // Google Map
  GoogleMapController? mapController;

  LatLng currentPosition = const LatLng(
    13.0827,
    80.2707,
  );

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentLocation();

    if (widget.driverId.isNotEmpty) {
      // Connect to AUSWAY_SERVER's Socket.IO so this driver can receive
      // "new-booking" pushes in real time.
      SocketService.onNewBooking = _handleNewBooking;
      SocketService.connect(widget.driverId);

      // Push GPS location to POST /api/location/driver every 2 seconds
      // so the server's nearest-driver search can find this driver.
      _tracking = DriverTrackingService(
        driverId: widget.driverId,
        ambulanceType: widget.ambulanceType,
      );
      _tracking!.startTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tracking?.stopTracking();
    if (widget.driverId.isNotEmpty) {
      SocketService.disconnect();
    }
    searchController.dispose();
    super.dispose();
  }

  // ===========================
  // APP LIFECYCLE
  // ===========================
  // Briefly backgrounding the app (screen off, switching apps) should
  // NOT log the driver out or drop their bookability — only actually
  // closing the app does that (dispose() above). This just makes sure
  // the socket + location tracking pick back up promptly on resume,
  // rather than waiting on the OS/library's own retry timing.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.driverId.isNotEmpty) {
      SocketService.ensureConnected();
      if (isOnline) {
        _tracking ??= DriverTrackingService(
          driverId: widget.driverId,
          ambulanceType: widget.ambulanceType,
        );
        _tracking!.startTracking();
      }
    }
  }

  // ===========================
  // INCOMING BOOKING
  // ===========================

  void _handleNewBooking(dynamic data) {
    // Defensive check — the server only routes requests to drivers it
    // believes are online, but don't show a request card if this device
    // has since gone offline locally.
    if (!isOnline) return;
    if (!mounted) return;

    final booking = Map<String, dynamic>.from(data as Map);

    setState(() {
      incomingBooking = booking;
      markers = _driverOnlyMarkers();
      markers.addAll(_requestMarkers(booking));
    });

    _fitRequestBounds(booking);
  }

  // Keeps only the "driver" (self) marker — used as a base before adding
  // the pickup/destination pins for a fresh incoming request.
  Set<Marker> _driverOnlyMarkers() {
    return markers.where((m) => m.markerId.value == "driver").toSet();
  }

  // Red pin = pickup, green pin = destination — same convention as
  // SetLocation.dart on the User App, so the driver sees exactly the
  // same two points the rider set.
  Set<Marker> _requestMarkers(Map<String, dynamic> booking) {
    final result = <Marker>{};

    final pickupLat = (booking["pickupLat"] as num?)?.toDouble();
    final pickupLng = (booking["pickupLng"] as num?)?.toDouble();
    final destLat = (booking["destLat"] as num?)?.toDouble();
    final destLng = (booking["destLng"] as num?)?.toDouble();

    if (pickupLat != null && pickupLng != null) {
      result.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(pickupLat, pickupLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: "Pickup",
            snippet: (booking["pickupAddress"] as String?) ?? "",
          ),
        ),
      );
    }

    if (destLat != null && destLng != null) {
      result.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: LatLng(destLat, destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Destination",
            snippet: (booking["destAddress"] as String?) ?? "",
          ),
        ),
      );
    }

    return result;
  }

  // Zooms/pans the map so both pins (and this driver) are visible as
  // soon as a request comes in, instead of the driver having to scroll.
  Future<void> _fitRequestBounds(Map<String, dynamic> booking) async {
    if (mapController == null) return;

    final points = <LatLng>[currentPosition];

    final pickupLat = (booking["pickupLat"] as num?)?.toDouble();
    final pickupLng = (booking["pickupLng"] as num?)?.toDouble();
    final destLat = (booking["destLat"] as num?)?.toDouble();
    final destLng = (booking["destLng"] as num?)?.toDouble();

    if (pickupLat != null && pickupLng != null) {
      points.add(LatLng(pickupLat, pickupLng));
    }
    if (destLat != null && destLng != null) {
      points.add(LatLng(destLat, destLng));
    }

    if (points.length < 2) return;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    try {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          60,
        ),
      );
    } catch (_) {
      // Bounds too tight (points on top of each other) — ignore, the
      // request card still shows the addresses either way.
    }
  }

  // Removes the pickup/destination pins once a request is accepted,
  // rejected, or otherwise dismissed.
  void _clearRequestMarkers() {
    markers = _driverOnlyMarkers();
  }

  // ===========================
  // LOCATION
  // ===========================

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition();

    currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    markers = {
      Marker(
        markerId: const MarkerId("driver"),
        position: currentPosition,
        infoWindow: const InfoWindow(
          title: "Your Location",
        ),
      ),
    };

    setState(() {});

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        currentPosition,
        16,
      ),
    );
  }

  // ===========================
  // SEARCH
  // ===========================

  Future<void> searchLocation(
      String value) async {
    if (value.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchResults = false;
      });
      return;
    }

    final results =
        await PlaceService.searchPlace(value);

    setState(() {
      searchResults = results;
      showSearchResults = true;
    });
  }

  // ===========================
  // BUTTONS
  // ===========================

  Future<void> acceptRide() async {
    final booking = incomingBooking;
    if (booking == null || isResponding) return;

    setState(() => isResponding = true);

    try {
      final result = await BookingService.acceptBooking(
        userId: booking["userId"].toString(),
        driverId: widget.driverId,
      );

      if (!mounted) return;

      if (result["status"] == true) {
        setState(() {
          incomingBooking = null;
          isResponding = false;
          _clearRequestMarkers();
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DriverNavigationPage(
              driverId: widget.driverId,
              ambulanceType: widget.ambulanceType,
              initialBooking: booking,
            ),
          ),
        );
      } else {
        setState(() => isResponding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]?.toString() ?? "Could not accept ride"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isResponding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting ride: $e")),
      );
    }
  }

  Future<void> rejectRide() async {
    final booking = incomingBooking;
    if (booking == null || isResponding) return;

    setState(() {
      incomingBooking = null;
      _clearRequestMarkers();
    });

    try {
      await BookingService.rejectBooking(
        userId: booking["userId"].toString(),
        driverId: widget.driverId,
      );
    } catch (_) {
      // Non-fatal — the card is already dismissed locally either way.
    }
  }

  void toggleOnline() {
    setState(() {
      isOnline = !isOnline;
      if (!isOnline) {
        // Going offline clears any pending request card — an offline
        // driver shouldn't be shown (or able to accept) a ride.
        incomingBooking = null;
        _clearRequestMarkers();
      }
    });

    if (widget.driverId.isEmpty) return;

    if (isOnline) {
      SocketService.goOnline(widget.driverId);
      _tracking ??= DriverTrackingService(
        driverId: widget.driverId,
        ambulanceType: widget.ambulanceType,
      );
      _tracking!.startTracking();
    } else {
      SocketService.goOffline(widget.driverId);
      _tracking?.stopTracking();
      // Tell the server this driver is no longer bookable.
      DriverLocationService.updateLocation(
        driverId: widget.driverId,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        ambulanceType: widget.ambulanceType,
        online: false,
      );
    }
  }
  @override
Widget build(BuildContext context) {
  final booking = incomingBooking;
  final showRideCard = isOnline && booking != null;

  return Scaffold(
    key: _scaffoldKey,

    drawer: Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF8E2A2A),
            ),
            child: Text(
              "MENU",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ),
          ListTile(title: Text("Profile")),
          ListTile(title: Text("History")),
          ListTile(title: Text("Logout")),
        ],
      ),
    ),

    body: Stack(
      children: [

        /// GOOGLE MAP
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          markers: markers,
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),

        /// SEARCH BAR
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Menu(),
                        ),
                      );
                    },
                    child: const Icon(Icons.menu),
                  ),

                  const SizedBox(width: 10),

                  const Icon(Icons.search),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: searchLocation,
                      decoration: const InputDecoration(
                        hintText: "Search Hospital / Location",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
                /// BOTTOM PANEL
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 330,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE6CACA),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                80,
                16,
                16,
              ),
              child: Column(
                children: [
                  /// INCOMING RIDE REQUEST CARD — only rendered when a
                  /// real request has come in AND this driver is online.
                  if (showRideCard)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE6E6),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (booking["userName"] as String?) ?? "Rider",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if ((booking["ambulanceType"] as String?) != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8E2A2A),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          booking["ambulanceType"].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Pickup — red dot, same convention as the
                                // red pin on the User App's SetLocation page.
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        (booking["pickupAddress"] as String?) ??
                                            "Pickup location shared",
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Destination — green dot, same convention
                                // as the green pin on SetLocation.dart.
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        (booking["destAddress"] as String?) ??
                                            "Destination not set",
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (isResponding)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else ...[
                            GestureDetector(
                              onTap: rejectRide,
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            GestureDetector(
                              onTap: acceptRide,
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE6E6),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "ADVERTISEMENT",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black38,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// START BUTTON
        Positioned(
          bottom: 270,
          left: MediaQuery.of(context).size.width / 2 -
              65,
          child: GestureDetector(
            onTap: toggleOnline,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFE6E6),
              ),
              child: Center(
                child: Text(
                  isOnline
                      ? "ONLINE"
                      : "OFFLINE",
                  style: TextStyle(
                    color: isOnline
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
