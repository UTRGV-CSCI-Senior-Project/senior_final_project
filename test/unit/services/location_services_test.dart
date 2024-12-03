
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/core/app_exception.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/user_location_controller.mocks.dart';

@GenerateMocks([GeolocatorPlatform, GeocodingService])


void main(){
  late LocationService locationService;
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  late MockGeocodingService mockGeocodingService;

  setUp((){
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    mockGeocodingService = MockGeocodingService();
    locationService = LocationService(mockGeolocatorPlatform, mockGeocodingService);
  });

    group('checkService', () {
      test('returns true when location service is enabled', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        
        final result = await locationService.checkService();
        
        expect(result, isTrue);
        verify(mockGeolocatorPlatform.isLocationServiceEnabled()).called(1);
      });

      test('returns false when location service is disabled', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        
        final result = await locationService.checkService();
        
        expect(result, isFalse);
        verify(mockGeolocatorPlatform.isLocationServiceEnabled()).called(1);
      });
    });
   
     group('checkPermission', () {
      test('returns true when permission is while in use', () async {
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        
        final result = await locationService.checkPermission();
        
        expect(result, isTrue);
      });

      test('returns true when permission is always', () async {
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        
        final result = await locationService.checkPermission();
        
        expect(result, isTrue);
      });

      test('returns false when permission is denied', () async {
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        
        final result = await locationService.checkPermission();
        
        expect(result, isFalse);
      });

      test('returns false when permission is denied forever', () async {
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.deniedForever);
        
        final result = await locationService.checkPermission();
        
        expect(result, isFalse);
      });
    });

    group('getCurrentLocation', () {
      final mockPosition = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0
      );

      test('throws exception when location service is disabled', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        
        expect(
          () => locationService.getCurrentLocation(),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'location-service-disabled'
          )),
        );
      });

      test('throws exception when location permission is denied', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        
        expect(
          () => locationService.getCurrentLocation(),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'location-permission-disabled'
          )),
        );
      });

      test('returns current position when service and permissions are available', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockGeolocatorPlatform.getCurrentPosition())
            .thenAnswer((_) async => mockPosition);
        
        final result = await locationService.getCurrentLocation();
        
        expect(result, equals(mockPosition));
      });

      test('throws AppException when getCurrentPosition fails', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockGeolocatorPlatform.getCurrentPosition())
            .thenThrow(Exception('Location error'));
        
        expect(
          () => locationService.getCurrentLocation(),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'get-location-error'
          )),
        );
      });
    });
    
group('getCurrentLatiLong', () {
      final mockPosition = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0,
        headingAccuracy: 0
      );

      test('returns list of latitude and longitude', () async {
        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockGeolocatorPlatform.getCurrentPosition())
            .thenAnswer((_) async => mockPosition);
        
        final result = await locationService.getCurrentLatiLong();
        
        expect(result, [40.7128, -74.0060]);
      });
    });

    group('calculateDistanceInMiles', () {
      final position1 = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        headingAccuracy: 0,
        altitudeAccuracy: 0
      );

      final position2 = Position(
        latitude: 34.0522,
        longitude: -118.2437,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        headingAccuracy: 0,
        altitudeAccuracy: 0
      );

      test('calculates distance between two positions in miles', () {
        when(mockGeolocatorPlatform.distanceBetween(
          position1.latitude,
          position1.longitude,
          position2.latitude,
          position2.longitude,
        )).thenReturn(3935000); // Approximate distance in meters

        final distance = locationService.calculateDistanceInMiles(position1, position2);
        
        expect(distance, closeTo(2444.42, 1)); // Approximate miles between NYC and LA
      });
    });

    group('getAddress', () {
      test('returns formatted address when placemarks are found', () async {
        final placemarks = [
          const Placemark(
            street: '123 Main St',
            locality: 'New York',
            administrativeArea: 'NY',
            country: 'USA',
          )
        ];

        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenAnswer((_) async => placemarks);
        
        final address = await locationService.getAddress(40.7128, -74.0060);
        
        expect(address, '123 Main St, New York, NY, USA');
      });

      test('throws AppException when no placemarks are found', () async {
        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenAnswer((_) async => []);
        
        expect(
          () => locationService.getAddress(40.7128, -74.0060),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'address-not-found'
          )),
        );
      });

      test('throws AppException on geocoding error', () async {
        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenThrow(Exception('Geocoding error'));
        
        expect(
          () => locationService.getAddress(40.7128, -74.0060),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'get-address-error'
          )),
        );
      });
    });

    group('getCity', () {
      test('returns city name when placemarks are found', () async {
        final placemarks = [
          const Placemark(
            locality: 'New York',
          )
        ];

        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenAnswer((_) async => placemarks);
        
        final city = await locationService.getCity(40.7128, -74.0060);
        
        expect(city, 'New York');
      });

      test('returns "City not found." when no placemarks are found', () async {
        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenAnswer((_) async => []);
        
        final city = await locationService.getCity(40.7128, -74.0060);
        
        expect(city, 'City not found.');
      });

      test('throws AppException on geocoding error', () async {
        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenThrow(Exception('Geocoding error'));
        
        expect(
          () => locationService.getCity(40.7128, -74.0060),
          throwsA(isA<AppException>().having(
            (e) => e.code, 
            'code', 
            'get-city-error'
          )),
        );
      });
    });

    group('getCurrentCity', () {
      final mockPosition = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0,
        headingAccuracy: 0
      );

      test('returns current city name', () async {
        final placemarks = [
          const Placemark(
            locality: 'New York',
          )
        ];

        when(mockGeolocatorPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocatorPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockGeolocatorPlatform.getCurrentPosition())
            .thenAnswer((_) async => mockPosition);
        when(mockGeocodingService.getPlacemarksFromCoordinates(40.7128, -74.0060))
            .thenAnswer((_) async => placemarks);
        
        final city = await locationService.getCurrentCity();
        
        expect(city, 'New York');
      });
    });

    group('createGeohash', () {
      test('creates a geohash for given coordinates', () {
        final geohash = locationService.createGeohash(40.7128, -74.0060);
        
        expect(geohash, isNotEmpty);
        expect(geohash.length, greaterThan(0));
      });
    });

    group('openLocationSettings', () {
      test('calls openLocationSettings on geolocator', () async {
        when(mockGeolocatorPlatform.openLocationSettings())
            .thenAnswer((_) async => true);
        
        await locationService.openLocationSettings();
        
        verify(mockGeolocatorPlatform.openLocationSettings()).called(1);
      });
    });

    group('getPositionStream', () {
      test('calls getPositionStream with correct location settings', () {
        when(mockGeolocatorPlatform.getPositionStream(
          locationSettings: const LocationSettings(
            distanceFilter: 32186,
          )
        )).thenAnswer((_) => const Stream.empty());
        
        final stream = locationService.getPositionStream();
        
        expect(stream, isA<Stream<Position>>());
      });
    });
}