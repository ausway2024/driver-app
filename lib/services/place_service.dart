import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceService {
  // Replace with your Google Maps API Key
  static const String apiKey = "AIzaSyDXkF_oXK_0d3OlwqirSwU3Dc_I9pXveRE";

  static Future<List<dynamic>> searchPlace(String query) async {
    if (query.isEmpty) return [];

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&components=country:in"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["predictions"];
    }

    return [];
  }
}