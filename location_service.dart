import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/index.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<Location?> getCurrentLocation() async {
    final position = await getCurrentPosition();
    if (position != null) {
      return Location(
        lat: position.latitude,
        lng: position.longitude,
      );
    }
    return null;
  }

  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.isNotEmpty) place.street!,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality!,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality!,
          if (place.country != null && place.country!.isNotEmpty)
            place.country!,
        ];
        return parts.join(', ');
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  static Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
