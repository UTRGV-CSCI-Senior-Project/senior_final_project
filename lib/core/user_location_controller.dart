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
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
return serviceEnabled;
}

Future<bool> checkPerm() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
    if (permission==LocationPermission.whileInUse|| permission==LocationPermission.always){
      return true;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied||permission == LocationPermission.deniedForever||permission == LocationPermission.unableToDetermine) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return false;
    }
  

  return true;
}

Future<Position> currentLocation() async {
  Future<bool> serviceEnabled;
  Future<bool> permission;
  try {
    serviceEnabled=checkService();
    permission=checkPerm();
  } catch (e) {
   return Future.error('could not get current location');
  }
  

  if (serviceEnabled==true&&permission==true){
    return await Geolocator.getCurrentPosition( );
  }
  
  
}

double distanceInMiles(Position p1,Position p2){
  return 0.000621*Geolocator.distanceBetween(p1.latitude, p1.longitude,p2.latitude , p2.longitude);
}

Future<String> currentAddress(double lati,double long) async {
  
  List<Placemark> placemarks = await placemarkFromCoordinates(
      lati,long);
  Placemark place = placemarks[0];
  return "${place.street}";
}



Future<String> curretCity(double lati,double long ) async {

  List<Placemark> placemarks = await placemarkFromCoordinates(
      lati,long);
  Placemark place = placemarks[0];
  return "${place.locality}";
}
