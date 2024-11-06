import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/views/settings/settings_screen.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/login_screen_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('SettingsScreen Tests', () {
    final testUserData = {
      'user': UserModel(
        uid: '123123',
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        isProfessional: false,
      ),
    };

    testWidgets('displays all settings options for non-professional user',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            userDataStreamProvider
                .overrideWith((ref) => Stream.value(testUserData)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Become a professional'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.text('FEEDBACK'), findsOneWidget);
      expect(find.text('Report a bug'), findsOneWidget);
      expect(find.text('Send feedback'), findsOneWidget);
    });

    testWidgets('shows logout confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            userDataStreamProvider
                .overrideWith((ref) => Stream.value(testUserData)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Are you sure you want to log out? You'll need to login again to use the app."), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);
    });

    testWidgets('calls signOut when logout confirmed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            userDataStreamProvider
                .overrideWith((ref) => Stream.value(testUserData)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();

      verify(mockUserRepository.signOut()).called(1);
    });

    testWidgets('displays professional options for professional user',
        (WidgetTester tester) async {
      final professionalUserData = {
        'user': UserModel(
          uid: '123123',
          username: 'testuser',
          email: 'test@example.com',
          fullName: 'Test User',
          isProfessional: true,
        ),
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            userDataStreamProvider
                .overrideWith((ref) => Stream.value(professionalUserData)),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage portfolio'), findsOneWidget);
      expect(find.text('Become a professional'), findsNothing);
    });
  });
}
