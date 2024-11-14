import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.\

Future<bool> checkService() async {
  bool serviceEnabled;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  return serviceEnabled;
}

Future<bool> checkPerm() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    return true;
  }
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever ||
      permission == LocationPermission.unableToDetermine) {
    // Permissions are denied, next time you could try
    // requesting permissions again (this is also where
    // Android's shouldShowRequestPermissionRationale
    // returned true. According to Android guidelines
    // your App should show an explanatory UI now.
    return false;
  }

  return true;
}

Future<List<double>> currentLocationLatiLong() async {
  bool serviceEnabled = await checkService();
  bool permission = await checkPerm();
  // ignore: unrelated_type_equality_checks
  if (serviceEnabled == false || permission == false) {
    return Future.error("Could not get current Location");
  }

  Position p = await Geolocator.getCurrentPosition();
  return [p.latitude, p.longitude];
}

/*Future<Map<String, dynamic>> initilizeUser()async {
  var location = await currentLocationLatiLong();
  var city = await curretCity(location[0], location[1]);
  return {'latitude': location[0], 'longitude': location[1], 'city': city};
}*/

double distanceInMiles(Position p1, Position p2) {
  return 0.000621 *
      Geolocator.distanceBetween(
          p1.latitude, p1.longitude, p2.latitude, p2.longitude);
}

Future<String> currentAddress(double lati, double long) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lati, long);
  Placemark place = placemarks[0];
  return "${place.street}";
}

Future<String> currentCity(double lati, double long) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lati, long);
  Placemark place = placemarks[0];
  return "${place.locality}";
}
