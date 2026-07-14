import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// NOTE: no longer called anywhere — registration now writes straight to
// Supabase's driver_profiles table (see "driver reg.dart"). Kept here in
// case you want a real backend-side registration endpoint later; if so,
// add POST /api/drivers/register + a controller on AUSWAY_SERVER first.
class DriverService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<http.Response> registerDriver({
    required String firstName,
    required String lastName,
    required String phone,
    required String emergencyContact,
    required String address,
    required String city,
    required String pincode,
    required String vehicleType,
  }) async {
    final url = Uri.parse("$baseUrl/drivers/register");

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "emergency_contact": emergencyContact,
        "address": address,
        "city": city,
        "pincode": pincode,
        "vehicle_type": vehicleType,
      }),
    );
  }
}