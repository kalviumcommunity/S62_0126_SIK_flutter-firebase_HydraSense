import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnown =
          await Geolocator.getLastKnownPosition();

      if (lastKnown != null) return lastKnown;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      return null;
    }
  }

  /// 🔍 REAL search – buildings, landmarks, addresses
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String query) async {
    final q = query.trim();
    if (q.length < 3) return [];

    final url = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': q,
        'format': 'jsonv2',
        'addressdetails': '1',
        'namedetails': '1',
        'limit': '10',
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'HydraSense/1.0 (contact: dev@hydrasense.app)',
        },
      );

      if (response.statusCode != 200) return [];

      final List data = json.decode(response.body);

      return data.map<Map<String, dynamic>>((item) {
        final address = item['address'] ?? {};

        final subtitle = [
          address['road'],
          address['suburb'],
          address['city'] ??
              address['town'] ??
              address['village'],
          address['state'],
        ].where((e) => e != null).join(', ');

        return {
          'display': item['namedetails']?['name'] ??
              item['display_name'],
          'address': subtitle,
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }
}