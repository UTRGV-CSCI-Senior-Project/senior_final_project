import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/create_portfolio_tabs/choose_service_screen.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late MockFirestoreServices mockFirestoreServices;

  setUp(() {
    mockFirestoreServices = MockFirestoreServices();
  });

  group('Choose Service Screen Tests', () {

    testWidgets('displays loading indicator while fetching services',
        (WidgetTester tester) async {
  

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
            servicesStreamProvider.overrideWith((ref){
              return Stream.value([]);
            })
          ],
          child: MaterialApp(
            home: ChooseService(onServiceSelected: (_) {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error view when service fetch fails',
        (WidgetTester tester) async {


      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
            servicesStreamProvider.overrideWith((ref){
              return Stream.error(Exception('Failed to fetch'));
            })
          ],
          child: MaterialApp(
            home: ChooseService(onServiceSelected: (_) {}),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ErrorView), findsOneWidget);
    });

    testWidgets('allows service selection', (WidgetTester tester) async {
      String? selectedService;


      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
            servicesStreamProvider.overrideWith((ref){
              return Stream.value(['Nail Tech', 'Barber', 'Tattoo Artist', 'Car Detailer']);
            })
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ChooseService(
                onServiceSelected: (service) => selectedService = service,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Barber'));
      expect(selectedService, equals('Barber'));
    });
  });
}
