import 'package:dart_geohash/dart_geohash.dart';
import 'package:folio/core/app_exception.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  final GeolocatorPlatform _geolocator;
  final GeocodingService _geocodingService;

  LocationService(this._geolocator, this._geocodingService);
  /// Check if location services are enabled.a
  Future<bool> checkService() async {
    return await _geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions.
  Future<bool> checkPermission() async {
    LocationPermission permission = await _geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      return false;
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
    if (!serviceEnabled) {
      throw AppException("location-service-disabled");
    }
    bool hasPermission = await checkPermission();

    if (!hasPermission) {
      throw AppException("location-permission-disabled");
    }

    try {
      return await _geolocator.getCurrentPosition();
    } catch (e) {
      throw AppException('get-location-error');
    }
  }

  Future<List<double>> getCurrentLatiLong() async {
    Position position = await getCurrentLocation();
    return [position.latitude, position.longitude];
  }

  /// Calculate distance between two points in miles.
  double calculateDistanceInMiles(Position p1, Position p2) {
    return 0.000621371 *
        _geolocator.distanceBetween(
          p1.latitude,
          p1.longitude,
          p2.latitude,
          p2.longitude,
        );
  }

  /// Get the street address for given latitude and longitude.
  Future<String> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await _geocodingService.getPlacemarksFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return [
          place.street ?? '',
          place.locality ?? '',
          place.administrativeArea ?? '',
          place.country ?? ''
        ].where((element) => element.isNotEmpty).join(', ');
      }
      throw AppException('address-not-found');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-address-error');
      }
    }
  }

  /// Get the city for given latitude and longitude.
  Future<String> getCity(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await _geocodingService.getPlacemarksFromCoordinates(latitude, longitude);
      return placemarks.isNotEmpty
          ? placemarks.first.locality ?? 'City not found.'
          : 'City not found.';
    } catch (e) {
      throw AppException('get-city-error');
    }
  }

  /// Fetch the current city of the device.
  Future<String> getCurrentCity() async {
    Position location = await getCurrentLocation();
    return await getCity(location.latitude, location.longitude);
  }

  String createGeohash(double latitude, double longitude) {
    return GeoHasher().encode(longitude, latitude);
  }

  Future<void> openLocationSettings() async {
    await _geolocator.openLocationSettings();
  }

  Stream<Position> getPositionStream() {
    return _geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      distanceFilter: 32186,
    ));
  }
}

class GeocodingService {
  Future<List<Placemark>> getPlacemarksFromCoordinates(
      double latitude, double longitude) {
    return placemarkFromCoordinates(latitude, longitude);
  }
}