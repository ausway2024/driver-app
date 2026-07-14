import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {

  //==================================================
  // SERVER URL — set once in lib/config/app_config.dart
  //==================================================

  static String get baseUrl => AppConfig.baseUrl;

  //==================================================
  // DRIVER LOCATION UPDATE
  //==================================================

  static Future<bool> updateDriverLocation({

    required String id,

    required double latitude,

    required double longitude,

    required String ambulanceType,

    required bool online,

  }) async {

    final response = await http.post(

      Uri.parse("$baseUrl/location/driver"),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "id": id,

        "latitude": latitude,

        "longitude": longitude,

        "ambulanceType": ambulanceType,

        "online": online,

      }),

    );

    return response.statusCode == 200;

  }

  //==================================================
  // GET ONLINE DRIVERS
  //==================================================

  static Future<dynamic> getDrivers() async {

    final response = await http.get(

      Uri.parse("$baseUrl/location/drivers"),

    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    }

    return null;

  }

  //==================================================
  // USER BOOKING
  //==================================================

  static Future<dynamic> requestBooking({

    required String userId,

    required double latitude,

    required double longitude,

    required String ambulanceType,

  }) async {

    final response = await http.post(

      Uri.parse("$baseUrl/bookings/request"),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "userId": userId,

        "latitude": latitude,

        "longitude": longitude,

        "ambulanceType": ambulanceType,

      }),

    );

    return jsonDecode(response.body);

  }

  //==================================================
  // OTP AUTH
  //==================================================

  static Future<http.Response> sendOTP(String phone) async {

    return http.post(

      Uri.parse("$baseUrl/otp/send"),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "phone": phone,

      }),

    );

  }

  static Future<http.Response> verifyOTP({

    required String phone,

    required String otp,

  }) async {

    return http.post(

      Uri.parse("$baseUrl/otp/verify"),

      headers: {

        "Content-Type": "application/json",

      },

      body: jsonEncode({

        "phone": phone,

        "otp": otp,

      }),

    );

  }

}