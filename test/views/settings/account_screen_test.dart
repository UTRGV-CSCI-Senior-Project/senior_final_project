import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/settings/account_screen.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/login_screen_test.mocks.dart';

void main(){
  late MockUserRepository mockUserRepository;

  setUp((){
    mockUserRepository = MockUserRepository();
  });

   group('AccountScreen Tests', () {
    final testUser = UserModel(
      uid: '123123',
      username: 'testuser',
      email: 'test@example.com',
      fullName: 'Test User',
      isProfessional: false,
    );

    testWidgets('displays user information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('shows editProfileSheet when username is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Username'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileSheet), findsOneWidget);
      expect(find.byType(TextField), findsExactly(2));
    });

    testWidgets('shows editProfileSheet when name is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Full Name'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileSheet), findsOneWidget);
      expect(find.byType(TextField), findsExactly(2));
    });

    testWidgets('calls reauthenticateUser and changeUserEmail when click on Email and fill in the information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      expect(find.text('Verify Password'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123123');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Change Email'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'newemail@email.com');
      await tester.tap(find.text('Update'));

      verify(mockUserRepository.reauthenticateUser('123123')).called(1);
      verify(mockUserRepository.changeUserEmail('newemail@email.com')).called(1);
    });

        testWidgets('calls reauthenticateUser and updateUserPassword when click on Password and fill in the information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Password'));
      await tester.pumpAndSettle();
      expect(find.text('Verify Password'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123123');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Update Password'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.tap(find.text('Update'));

      verify(mockUserRepository.reauthenticateUser('123123')).called(1);
      verify(mockUserRepository.updateUserPassword('123456')).called(1);
    });

    testWidgets('delete account button shows dialog, calls reauthenticateUser, and calls deleteUserAccount', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: AccountScreen(user: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE ACCOUNT'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want delete your account? All your account data will be lost.'), findsOneWidget);
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();
       expect(find.text('Verify Password'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123123');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      verify(mockUserRepository.reauthenticateUser('123123')).called(1);
      verify(mockUserRepository.deleteUserAccount()).called(1);
    });
  });
}