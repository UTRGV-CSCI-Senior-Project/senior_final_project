import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/create_portfolio_tabs/choose_service_screen.dart';
import 'package:folio/widgets/adding_denied_dialog.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:folio/widgets/successfully_added_dialog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/services/gemini_services.dart';

import '../../mocks/user_repository_test.mocks.dart';
import '../../mocks/choose_service_screen_test.mocks.dart';

@GenerateMocks([GeminiServices])
void main() {
  late MockGeminiServices mockGeminiServices;
  late MockFirestoreServices mockFirestoreServices;

  setUp(() {
    mockGeminiServices = MockGeminiServices();
    mockFirestoreServices = MockFirestoreServices();
  });

  group('Choose Service Screen Tests', () {
    testWidgets('displays loading indicator while fetching services',
        (WidgetTester tester) async {
      final completer = Completer<List<String>>();

      when(mockFirestoreServices.getServices())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
          ],
          child: MaterialApp(
            home: ChooseService(onServiceSelected: (_) {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Try searching in TextField and show it exists',
        (tester) async {
      final mockServices = ['Service 1', 'Service 2', 'Service 3'];
      when(mockFirestoreServices.getServices())
          .thenAnswer((_) async => mockServices);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        ],
        child: MaterialApp(
          home: ChooseService(onServiceSelected: (service) {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Let's get your profile ready!"), findsOneWidget);
      expect(find.text('What service do you offer?'), findsOneWidget);
      expect(find.text('Search Folio'), findsOneWidget);
      expect(find.text('Service 1'), findsOneWidget);
      expect(find.text('Service 2'), findsOneWidget);
      expect(find.text('Service 3'), findsOneWidget);

      final textFieldFinder = find.byKey(const Key('choose-service-textfield'));
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, 'Ser');
      await tester.pumpAndSettle();

      expect(find.text('Service 1'), findsOneWidget);
      expect(find.text('Service 2'), findsOneWidget);
      expect(find.text('Service 3'), findsOneWidget);
    });

    testWidgets('Try searching in TextField and show it does not exists',
        (tester) async {
      final mockServices = ['Service 1', 'Service 2', 'Service 3'];
      when(mockFirestoreServices.getServices())
          .thenAnswer((_) async => mockServices);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        ],
        child: MaterialApp(
          home: ChooseService(onServiceSelected: (service) {}),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text("Let's get your profile ready!"), findsOneWidget);
      expect(find.text('What service do you offer?'), findsOneWidget);
      expect(find.text('Search Folio'), findsOneWidget);
      expect(find.text('Service 1'), findsOneWidget);
      expect(find.text('Service 2'), findsOneWidget);
      expect(find.text('Service 3'), findsOneWidget);

      final textFieldFinder = find.byKey(const Key('choose-service-textfield'));
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, 'PPP');
      await tester.pumpAndSettle();

      expect(
          find.text('No services found matching your search.'), findsOneWidget);
      expect(find.text('Add to Career List'), findsOneWidget);
    });
  });
}
