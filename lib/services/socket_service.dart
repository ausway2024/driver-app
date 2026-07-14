import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {

  static IO.Socket? socket;

  static bool isConnected = false;

  /// Set from HomePage to react to a real incoming booking request.
  static void Function(dynamic data)? onNewBooking;

  static String? _lastDriverId;

  static void connect(String driverId) {

    _lastDriverId = driverId;

    socket = IO.io(

      AppConfig.socketUrl,

      IO.OptionBuilder()

          .setTransports(['websocket'])

          .disableAutoConnect()

          .enableForceNew()

          // Keep retrying in the background — this is what lets the
          // driver come back online automatically after a brief network
          // drop or the app being backgrounded, without needing to log
          // in again.
          .enableReconnection()

          .setReconnectionAttempts(9999)

          .setReconnectionDelay(2000)

          .build(),

    );

    socket!.connect();

    socket!.onConnect((_) {

      isConnected = true;

      print("Socket Connected");

      socket!.emit("driver-online", driverId);

      print("Driver Registered : $driverId");

    });

    socket!.onDisconnect((_) {

      isConnected = false;

      print("Socket Disconnected");

    });

    socket!.onConnectError((data) {

      print("Socket Error : $data");

    });

    socket!.onError((data) {

      print("Socket General Error : $data");

    });

    // Receive Booking
    socket!.on("new-booking", (data) {

      print("NEW BOOKING RECEIVED");
      print(data);

      onNewBooking?.call(data);

    });

  }

  /// Call this if you suspect the socket dropped and didn't auto-reconnect
  /// (e.g. on app resume from background) — safe to call even if it's
  /// already connected.
  static void ensureConnected() {
    if (isConnected) return;
    if (_lastDriverId == null) return;
    connect(_lastDriverId!);
  }

  /// Explicitly tell the server this driver is bookable again. The
  /// socket stays connected either way (see driver home page) — this
  /// just flips the server's presence flag immediately, instead of
  /// only via the periodic REST location ping.
  static void goOnline(String driverId) {
    socket?.emit("driver-online", driverId);
  }

  /// Explicitly tell the server this driver just went offline. Unlike a
  /// dropped connection (which the server treats with a grace period in
  /// case of a brief network blip), this is immediate — the driver made
  /// a deliberate choice.
  static void goOffline(String driverId) {
    socket?.emit("driver-offline", driverId);
  }

  /// Emits a live position ping during an active ride so the assigned
  /// rider's map marker updates instantly (the server relays this
  /// straight to them) rather than only via the slower REST location
  /// poll.
  static void sendLocation(String driverId, double latitude, double longitude) {
    socket?.emit("driver-location", {
      "driverId": driverId,
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  static void disconnect() {

    socket?.disconnect();

  }

}
