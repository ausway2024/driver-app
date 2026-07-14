import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BookingService {
  static String get baseUrl => AppConfig.baseUrl;

  /// Driver taps the check mark on an incoming request.
  static Future<Map<String, dynamic>> acceptBooking({
    required String userId,
    required String driverId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/accept"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "driverId": driverId,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Driver taps the cross mark on an incoming request.
  static Future<Map<String, dynamic>> rejectBooking({
    required String userId,
    required String driverId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/reject"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "driverId": driverId,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Re-fetches the driver's current accepted booking — used by
  /// DriverNavigationPage if it's opened without ride data already in
  /// hand (e.g. after an app restart mid-ride).
  static Future<Map<String, dynamic>?> getActiveBooking(String driverId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/bookings/driver/$driverId/active"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == true) return data["booking"];
    }
    return null;
  }

  /// Driver taps "Complete Ride" once the trip is finished.
  static Future<Map<String, dynamic>> completeBooking({
    required String userId,
    required String driverId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/complete"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "driverId": driverId,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Driver cancels an in-progress ride.
  static Future<Map<String, dynamic>> cancelBooking({
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings/cancel"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "cancelledBy": "driver",
      }),
    );
    return jsonDecode(response.body);
  }
}
