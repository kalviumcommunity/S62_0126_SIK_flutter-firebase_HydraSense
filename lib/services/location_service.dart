import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/rate_limiter.dart';

class LocationService {
  final RateLimiter _searchLimiter =
      RateLimiter(const Duration(seconds: 1));

  Future<Position?> getCurrentLocation() async {
    try {
      // 1️⃣ Check if location services are enabled
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services disabled');
        return null;
      }

      // 2️⃣ Check & request permission
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('❌ Location permission denied');
        return null;
      }

      // 3️⃣ Try last known position (FAST, reliable)
      final lastKnown =
          await Geolocator.getLastKnownPosition();

      if (lastKnown != null) {
        print('📍 Using last known location');
        return lastKnown;
      }

      // 4️⃣ Fallback: request current position (NO timeout)
      print('📡 Requesting current GPS fix...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      print('❌ Location error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaceSuggestions(
      String query) async {
    if (query.trim().length < 3) return [];
    if (!_searchLimiter.shouldAllow()) return [];

    final url = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '3',
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'HydraSense/1.0'},
      );

      if (response.statusCode != 200) return [];

      final List data = json.decode(response.body);

      return data.map<Map<String, dynamic>>((item) {
        return {
          'display': item['display_name'],
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
