import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'services/booking_service.dart';
import 'services/driver_location_service.dart';
import 'services/socket_service.dart';

double _haversineMetres(LatLng a, LatLng b) {
  const R = 6371000.0;
  final dLat = (b.latitude - a.latitude) * pi / 180;
  final dLon = (b.longitude - a.longitude) * pi / 180;
  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(a.latitude * pi / 180) *
          cos(b.latitude * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return 2 * R * asin(sqrt(h));
}

class DriverNavigationPage extends StatefulWidget {
  final String driverId;
  final String ambulanceType;

  /// Booking data handed straight from the accept button on the home
  /// page. If this page is opened without it (e.g. app restarted mid
  /// ride), it falls back to fetching the active booking from the
  /// server.
  final Map<String, dynamic>? initialBooking;

  const DriverNavigationPage({
    super.key,
    required this.driverId,
    required this.ambulanceType,
    this.initialBooking,
  });

  @override
  State<DriverNavigationPage> createState() =>
      _DriverNavigationPageState();
}

class _DriverNavigationPageState
    extends State<DriverNavigationPage> {

  //---------------------------------------
  // GOOGLE MAP
  //---------------------------------------

  GoogleMapController? mapController;

  LatLng currentPosition =
      const LatLng(
    13.0827,
    80.2707,
  );

  //---------------------------------------
  // CURRENT RIDE (raw booking map from the server)
  //---------------------------------------

  Map<String, dynamic>? currentRide;

  bool isCompleting = false;

  bool isLoading = true;

  //---------------------------------------
  // MAP DATA
  //---------------------------------------

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  //---------------------------------------
  // ROUTE INFO (straight-line estimate — no Directions API call here)
  //---------------------------------------

  double distanceMetres = 0;

  double etaMinutes = 0;

  //---------------------------------------
  // TIMER
  //---------------------------------------

  Timer? trackingTimer;

  //---------------------------------------
  // INIT
  //---------------------------------------

  @override
  void initState() {

    super.initState();

    initialize();

  }

  @override
  void dispose() {

    trackingTimer?.cancel();

    mapController?.dispose();

    super.dispose();

  }

  //---------------------------------------
  // INITIALIZE
  //---------------------------------------

  Future<void> initialize() async {

    await getCurrentLocation();

    await loadRide();

    startTracking();

  }

  //---------------------------------------
  // START TIMER
  //---------------------------------------

  void startTracking() {

    trackingTimer =
        Timer.periodic(

      const Duration(
        seconds: 2,
      ),

      (_) async {

        await getCurrentLocation();

        await pushLiveLocation();

      },

    );

  }

  //---------------------------------------
  // DRIVER LOCATION
  //---------------------------------------

  Future<void> getCurrentLocation() async {

    bool enabled =
        await Geolocator
            .isLocationServiceEnabled();

    if (!enabled) return;

    LocationPermission permission =
        await Geolocator
            .checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator
              .requestPermission();

    }

    if (permission ==
        LocationPermission.deniedForever) {

      return;

    }

    Position position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.best,
    );

    currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    markers.removeWhere(
      (marker) =>
          marker.markerId.value ==
          "driver",
    );

    markers.add(

      Marker(

        markerId:
            const MarkerId(
          "driver",
        ),

        position:
            currentPosition,

        infoWindow:
            const InfoWindow(
          title:
              "You",
        ),

        icon:
            BitmapDescriptor
                .defaultMarkerWithHue(
          BitmapDescriptor
              .hueBlue,
        ),

      ),

    );

    _recalculateRoute();

    setState(() {});

  }
    //---------------------------------------
  // LOAD CURRENT RIDE
  //---------------------------------------

  Future<void> loadRide() async {

    Map<String, dynamic>? ride = widget.initialBooking;

    // No ride data passed in (e.g. app was restarted mid-ride) — ask the
    // server for whatever's currently accepted for this driver.
    ride ??= await BookingService.getActiveBooking(widget.driverId);

    if (ride == null) {

      setState(() {
        isLoading = false;
      });

      return;

    }

    currentRide = ride;

    final pickupLat = (ride["pickupLat"] as num?)?.toDouble();
    final pickupLng = (ride["pickupLng"] as num?)?.toDouble();
    final destLat = (ride["destLat"] as num?)?.toDouble();
    final destLng = (ride["destLng"] as num?)?.toDouble();

    if (pickupLat != null && pickupLng != null) {
      markers.add(

        Marker(

          markerId:
              const MarkerId(
            "pickup",
          ),

          position: LatLng(pickupLat, pickupLng),

          infoWindow:
              const InfoWindow(
            title: "Pickup",
          ),

          icon:
              BitmapDescriptor
                  .defaultMarkerWithHue(
            BitmapDescriptor
                .hueGreen,
          ),

        ),

      );
    }

    if (destLat != null && destLng != null) {
      markers.add(

        Marker(

          markerId:
              const MarkerId(
            "destination",
          ),

          position: LatLng(destLat, destLng),

          infoWindow:
              const InfoWindow(
            title: "Destination",
          ),

          icon:
              BitmapDescriptor
                  .defaultMarkerWithHue(
            BitmapDescriptor
                .hueRed,
          ),

        ),

      );
    }

    _recalculateRoute();

    setState(() {

      isLoading = false;

    });

  }

  //---------------------------------------
  // ROUTE (straight-line estimate to pickup)
  //---------------------------------------
  // NOTE: AUSWAY_SERVER has no turn-by-turn directions endpoint yet, so
  // this draws a straight line and estimates ETA off an assumed average
  // speed rather than real road distance/time. Good enough to orient
  // the driver; swap in a Directions API call later for accuracy.

  void _recalculateRoute() {

    if (currentRide == null) return;

    final pickupLat = (currentRide!["pickupLat"] as num?)?.toDouble();
    final pickupLng = (currentRide!["pickupLng"] as num?)?.toDouble();

    if (pickupLat == null || pickupLng == null) return;

    final pickup = LatLng(pickupLat, pickupLng);

    distanceMetres = _haversineMetres(currentPosition, pickup);

    const assumedSpeedMetresPerSecond = 9.2; // ~33 km/h in traffic
    etaMinutes = (distanceMetres / assumedSpeedMetresPerSecond) / 60;

    polylines = {
      Polyline(
        polylineId: const PolylineId("driver_route"),
        points: [currentPosition, pickup],
        width: 5,
        color: Colors.blue,
      ),
    };

  }

  //---------------------------------------
  // PUSH LIVE LOCATION TO SERVER
  //---------------------------------------

  Future<void> pushLiveLocation() async {

    await DriverLocationService.updateLocation(
      driverId: widget.driverId,
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      ambulanceType: widget.ambulanceType,
      online: true,
    );

    // Also relay over the socket for an instant marker update on the
    // rider's map, instead of waiting on their next poll of this same
    // REST data.
    SocketService.sendLocation(
      widget.driverId,
      currentPosition.latitude,
      currentPosition.longitude,
    );

  }

  //---------------------------------------
  // COMPLETE / CANCEL RIDE
  //---------------------------------------

  Future<void> _completeRide() async {
    final ride = currentRide;
    if (ride == null || isCompleting) return;

    setState(() => isCompleting = true);

    try {
      final result = await BookingService.completeBooking(
        userId: ride["userId"].toString(),
        driverId: widget.driverId,
      );

      if (!mounted) return;

      if (result["status"] == true) {
        Navigator.pop(context);
      } else {
        setState(() => isCompleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]?.toString() ?? "Could not complete ride"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error completing ride: $e")),
      );
    }
  }

  Future<void> _cancelRide() async {
    final ride = currentRide;
    if (ride == null || isCompleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel this ride?"),
        content: const Text("The rider will be notified immediately."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isCompleting = true);

    try {
      await BookingService.cancelBooking(userId: ride["userId"].toString());
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling ride: $e")),
      );
    }
  }
    //---------------------------------------
  // UI
  //---------------------------------------

  @override
  Widget build(BuildContext context) {

    final ride = currentRide;

    return Scaffold(

      appBar: AppBar(

        backgroundColor: const Color(
          0xFF8E2A2A,
        ),

        title: const Text(
          "Driver Navigation",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

      ),

      body: Stack(

        children: [

          //---------------------------------------
          // GOOGLE MAP
          //---------------------------------------

          GoogleMap(

            initialCameraPosition:
                CameraPosition(

              target: currentPosition,

              zoom: 15,

            ),

            myLocationEnabled: true,

            myLocationButtonEnabled:
                true,

            zoomControlsEnabled:
                false,

            markers: markers,

            polylines: polylines,

            onMapCreated:
                (controller) {

              mapController =
                  controller;

            },

          ),

          //---------------------------------------
          // BOTTOM PANEL
          //---------------------------------------

          Align(

            alignment:
                Alignment.bottomCenter,

            child: Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  const BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(

                  top: Radius.circular(
                    25,
                  ),

                ),

                boxShadow: [

                  BoxShadow(

                    color:
                        Colors.black26,

                    blurRadius: 12,

                  )

                ],

              ),

              child: isLoading

                  ? const SizedBox(

                      height: 170,

                      child: Center(

                        child:
                            CircularProgressIndicator(),

                      ),

                    )

                  : ride == null

                      ? const SizedBox(

                          height: 170,

                          child: Center(

                            child: Text(

                              "No Active Ride",

                              style: TextStyle(

                                fontSize: 18,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                          ),

                        )

                      : Column(

                          mainAxisSize:
                              MainAxisSize.min,

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(

                              "Patient Details",

                              style: TextStyle(

                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 20,

                              ),

                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            Text(
                              "\u{1F464} ${(ride["userName"] as String?) ?? 'Rider'}",
                            ),

                            if ((ride["userPhone"] as String?)?.isNotEmpty == true) ...[
                              const SizedBox(height: 5),
                              Text(
                                "\u{1F4DE} ${ride["userPhone"]}",
                              ),
                            ],

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "\u{1F4CD} ${(ride["pickupAddress"] as String?) ?? 'Pickup location shared'}",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "\u{1F3E5} ${(ride["destAddress"] as String?) ?? 'Destination not set'}",
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            Row(

                              children: [

                                Expanded(

                                  child: Card(

                                    child: Padding(

                                      padding:
                                          const EdgeInsets.all(
                                        12,
                                      ),

                                      child: Column(

                                        children: [

                                          const Text(
                                            "Distance",
                                          ),

                                          const SizedBox(
                                            height: 8,
                                          ),

                                          Text(
                                            "${(distanceMetres / 1000).toStringAsFixed(2)} km",
                                          ),

                                        ],

                                      ),

                                    ),

                                  ),

                                ),

                                Expanded(

                                  child: Card(

                                    child: Padding(

                                      padding:
                                          const EdgeInsets.all(
                                        12,
                                      ),

                                      child: Column(

                                        children: [

                                          const Text(
                                            "ETA",
                                          ),

                                          const SizedBox(
                                            height: 8,
                                          ),

                                          Text(
                                            "${etaMinutes.toStringAsFixed(0)} mins",
                                          ),

                                        ],

                                      ),

                                    ),

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF8E2A2A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isCompleting ? null : _completeRide,
                                child: isCompleting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "COMPLETE RIDE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF8E2A2A)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isCompleting ? null : _cancelRide,
                                child: const Text(
                                  "CANCEL RIDE",
                                  style: TextStyle(
                                    color: Color(0xFF8E2A2A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
