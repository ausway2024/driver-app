import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class DriverLocationService {

  // Set once in lib/config/app_config.dart
  static String get baseUrl => AppConfig.baseUrl;

  static Future<bool> updateLocation({

    required String driverId,

    required double latitude,

    required double longitude,

    required String ambulanceType,

    required bool online,

  }) async {

    try {

      final response = await http.post(

        Uri.parse("$baseUrl/location/driver"),

        headers: {

          "Content-Type": "application/json",

        },

        body: jsonEncode({

          "id": driverId,

          "latitude": latitude,

          "longitude": longitude,

          "ambulanceType": ambulanceType,

          "online": online,

        }),

      );

      if (response.statusCode == 200) {

        print("Driver Location Updated");

        return true;

      }

      print(response.body);

      return false;

    } catch (e) {

      print("Driver Location Error : $e");

      return false;

    }

  }

}