import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// ⚠️ AUSWAY_SERVER has no /api/maps/route route yet — this will fail
/// (caught below) until you add it, or switch this to call the Google
/// Directions API directly the way the User App's SetLocation.dart does.
class MapService {

  static String get baseUrl => AppConfig.socketUrl;

  static Future<Map<String, dynamic>?> getRoute({
    required String origin,
    required String destination,
  }) async {

    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/maps/route?origin=$origin&destination=$destination",
        ),
      );

      if (response.statusCode == 200) {

        return jsonDecode(response.body);

      }

      return null;

    } catch (e) {

      print(e);

      return null;

    }

  }
}