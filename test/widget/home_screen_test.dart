import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home_screen.dart';
import 'package:folio/views/loading_screen.dart';
import 'package:folio/views/onboarding_screen.dart';
import 'package:folio/views/welcome_screen.dart';
import 'package:mockito/mockito.dart';
import '../mocks/login_screen_test.mocks.dart';
import '../mocks/user_repository_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockFirestoreServices mockFirestoreServices;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockFirestoreServices = MockFirestoreServices();
    when(mockFirestoreServices.getServices()).thenAnswer((_) async => [
          'Nail Tech',
          'Barber',
          'Tattoo Artist',
          'Car Detailer',
          'Hair Stylist'
        ]);
  });

  ProviderContainer createProviderContainer({UserModel? userModel}) {
    return ProviderContainer(
      overrides: [
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        userStreamProvider.overrideWith((ref) => Stream.value(userModel)),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  }

  Widget createHomeScreen(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  group('Home Screen', () {
    testWidgets('shows WelcomeScreen when user is null',
        (WidgetTester tester) async {
      final container = createProviderContainer(userModel: null);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('shows OnboardingScreen when onboarding not completed',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: false,
        // Add other required fields based on your UserModel
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('shows main interface when user is logged in and onboarded',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Check if the app bar shows correct welcome message
      expect(find.textContaining('Welcome, Test User!'), findsOneWidget);

      // Verify navigation bar is present with all items
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('navigation works correctly', (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      // Initially should be on home tab
      expect(find.text('Welcome, Test User!'), findsOneWidget);

      // Tap discover tab
      await tester.tap(find.byIcon(Icons.explore));
      await tester.pumpAndSettle();
      expect(find.text('Discover'), findsExactly(2));

      // Tap profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsExactly(2));
    });

    testWidgets('shows loading screen when stream is loading',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          userStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
      );

      await tester.pumpWidget(createHomeScreen(container));
      expect(find.byType(LoadingScreen), findsOneWidget);
    });

    testWidgets('can go to update services screen and update services',
        (WidgetTester tester) async {
      final userModel = UserModel(
          uid: 'testuid',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false,
          fullName: 'Test User',
          completedOnboarding: true,
          preferredServices: ['Nail Tech', 'Hair Stylist']);

      when(mockUserRepository.updateProfile(fields: {
        'preferredServices': ['Nail Tech', 'Barber', 'Hair Stylist']
      })).thenAnswer((_) async {});

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      expect(find.text("NAIL TECH"), findsOneWidget);
      expect(find.text("HAIR STYLIST"), findsOneWidget);
      expect(find.text("Edit"), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Update Your Interests!'), findsOneWidget);

      expect(find.byIcon(Icons.check), findsExactly(2));
      await tester.tap(find.text('Barber'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsExactly(3));
      await tester.tap(find.text('Update!'));
      await tester.pumpAndSettle();
      // Verify the update was called
      verify(mockUserRepository.updateProfile(fields: {
        'preferredServices': ['Nail Tech', 'Barber', 'Hair Stylist']
      })).called(1);
    });
  });
}
