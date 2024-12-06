import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/discover_tab.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/create_portfolio_screen_test.mocks.dart';
import '../../mocks/discover_tab_test.mocks.dart';
import '../../mocks/service_locator_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  final user = UserModel(
      uid: '1',
      fullName: 'Test User',
      username: 'username',
      email: 'email@email.com',
      isProfessional: false,
      preferredServices: ['Barber', 'Nail Tech']);

  late ProviderContainer container;
  late MockLocationService mockLocationService;
  late Position position;
  late MockGeminiServices mockGeminiServices;
  late MockPortfolioRepository mockPortfolioRepository;

  setUp(() {
    mockLocationService = MockLocationService();
    mockGeminiServices = MockGeminiServices();
    mockPortfolioRepository = MockPortfolioRepository();
    position = Position(
        latitude: 40.64,
        longitude: -74.0059,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0,
        headingAccuracy: 0);
    container = ProviderContainer(overrides: [
      geminiServicesProvider.overrideWithValue(mockGeminiServices),
      portfolioRepositoryProvider.overrideWithValue(mockPortfolioRepository),
      locationServiceProvider.overrideWithValue(mockLocationService),
      currentPositionProvider.overrideWith((ref) {
        return position;
      }),
      nearbyPortfoliosProvider.overrideWith((ref) {
        return [
          PortfolioModel(
            service: 'Photographer A',
            uid: 'test-uid',
            details: 'Professional photography',
            years: 6,
            months: 7,
            images: [],
            location: {'city': 'City', 'state': 'state'},
            latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
            professionalsName: 'Test Name',
          ),
          PortfolioModel(
            service: 'Barber B',
            uid: 'test-uid2',
            details: 'Professional barber',
            years: 5,
            months: 7,
            images: [],
            location: {'city': 'Hidalgo', 'state': 'Texas'},
            latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
            professionalsName: 'Test Name2',
          )
        ];
      })
    ]);
  });
  group('DiscoverTab Tests', () {
    testWidgets('search bar can receive input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DiscoverTab(userModel: user),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test search');
      expect(find.text('test search'), findsOneWidget);
    });
    testWidgets('nearby portfolios load and display correctly',
        (WidgetTester tester) async {
      when(mockLocationService.distanceInMiles(position, 40.7128, -74.006))
          .thenReturn(4);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: DiscoverTab(userModel: user),
            ),
          ),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      expect(find.text('Photographer A'), findsOneWidget);
      expect(find.text('Barber B'), findsOneWidget);
    });

    testWidgets('search updates results based on query',
        (WidgetTester tester) async {
          when(mockLocationService.distanceInMiles(position, 40.7128, -74.006))
          .thenReturn(4);
          when(mockGeminiServices.aiDiscover('Photographer')).thenAnswer((_) async => ['Photographer']);
          when(mockPortfolioRepository.getDiscoverPortfolios(['Photographer'])).thenAnswer((_) async => [PortfolioModel(
            service: 'Photographer A',
            uid: 'test-uid',
            details: 'Professional photography',
            years: 6,
            months: 7,
            images: [],
            location: {'city': 'City', 'state': 'state'},
            latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
            professionalsName: 'Test Name',
          ),]);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: DiscoverTab(userModel: user),
            ),
          ),
        ),
      );

      // Simulate a search
      await tester.enterText(find.byType(TextField), 'Photographer');
      await tester.pumpAndSettle();

      expect(find.text('Photographer A'), findsOneWidget);
            expect(find.text('Test Name'), findsOneWidget);

    });

    testWidgets('displays message for no nearby portfolios',
        (WidgetTester tester) async {
           when(mockLocationService.distanceInMiles(position, 40.7128, -74.006))
          .thenReturn(4);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
      geminiServicesProvider.overrideWithValue(mockGeminiServices),
      portfolioRepositoryProvider.overrideWithValue(mockPortfolioRepository),
      locationServiceProvider.overrideWithValue(mockLocationService),
      currentPositionProvider.overrideWith((ref) {
        return position;
      }),
      nearbyPortfoliosProvider.overrideWith((ref) {
        return [];
        })],
          child: MaterialApp(
            home: Scaffold(
              body: DiscoverTab(userModel: user),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No portfolios were found.'), findsOneWidget);
    });
  });
}
