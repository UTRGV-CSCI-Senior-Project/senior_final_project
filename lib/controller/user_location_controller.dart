import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Check if location services are enabled.
Future<bool> checkService() async {
  return await Geolocator.isLocationServiceEnabled();
}

/// Check and request location permissions.
Future<bool> checkPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    return true;
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Return false if permissions are still denied or denied forever.
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return false;
  }

  return true;
}

/// Fetch the current latitude and longitude.
Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await checkService();
  bool hasPermission = await checkPermission();

  if (!serviceEnabled) {
    throw Exception("Location services are disabled.");
  }

  if (!hasPermission) {
    throw Exception("Location permissions are denied.");
  }

  Position position = await Geolocator.getCurrentPosition();
  return position;
}

Future<List<double>> getCurrentLatiLong() async {
  Position position = await Geolocator.getCurrentPosition();
  return [position.latitude, position.longitude];
}

/// Calculate distance between two points in miles.
double calculateDistanceInMiles(Position p1, Position p2) {
  return 0.000621371 *
      Geolocator.distanceBetween(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
}

/// Get the street address for given latitude and longitude.
Future<String> getAddress(double latitude, double longitude) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  if (placemarks.isNotEmpty) {
    Placemark place = placemarks.first;
    return "${place.street}, ${place.locality}, ${place.country}";
  }
  return "Address not found.";
}

/// Get the city for given latitude and longitude.
Future<String> getCity(double latitude, double longitude) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
  if (placemarks.isNotEmpty) {
    return placemarks.first.locality ?? "City not found.";
  }
  return "City not found.";
}

/// Fetch the current city of the device.
Future<String> getCurrentCity() async {
  Position location = await getCurrentLocation();
  return await getCity(location.latitude, location.longitude);
}
