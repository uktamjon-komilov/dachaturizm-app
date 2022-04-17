import 'package:geolocator/geolocator.dart';

double calculateDistance(lat1, lon1, lat2, lon2) {
  return double.parse(
      (Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 100000)
          .toStringAsFixed(2));
}
