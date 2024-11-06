import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/views/auth_onboarding_welcome/auth_screen.dart';

@GenerateMocks([UserRepository])
import '../../mocks/signup_screen_test.mocks.dart';

void main() {
  //Create necessary mocks and keys for necessary fields
  late MockUserRepository mockUserRepository;
  final usernameField = find.byKey(const Key('username-field'));
  final emailField = find.byKey(const Key('email-field'));
  final passwordField = find.byKey(const Key('password-field'));
  final signUpButton = find.byKey(const Key('signup-button'));

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  ProviderContainer createProviderContainer() {
    return ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(mockUserRepository)],
    );
  }

  Widget createSignUpWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AuthScreen(isLogin: false),
        ));
  }

  group('sign up page', () {
    testWidgets('shows all necessary fields', (WidgetTester tester) async {
      //Load the sign up screen
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Expect all the fields to be found
      expect(usernameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(signUpButton, findsOneWidget);
    });

    testWidgets('Shows error on empty fields', (WidgetTester tester) async {
      //Load the sign up screen
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Tap sign up button without entering necessary data
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      //Expect to find error for empty fields
      expect(find.text('Please fill in all required fields to continue.'), findsOneWidget);
    });

    testWidgets('Calls createUser when username, email, password, are entered',
        (WidgetTester tester) async {
      //Create necessary data for user and load sign up screen
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter all data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign up button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);

      //Verify that the createUser (from userrepository) was called
      verify(mockUserRepository.createUser(username, email, password))
          .called(1);
    });

    testWidgets('Shows error when username is taken',
        (WidgetTester tester) async {
      //Create neccessary data, and load sign up screen
      const username = 'takenUsername';
      const email = 'email@email.com';
      const password = 'Pass123!';
      //when createUser is called, throw the username-taken
      when(mockUserRepository.createUser(username, email, password))
          .thenThrow(AppException('username-taken'));
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter necessary data to corresponding fields (using a taken username)
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign up button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      //Expect to see error with taken username message
      expect(
          find.textContaining(
              'This username is already taken. Please try a different one.'),
          findsOneWidget);
    });

    testWidgets('shows error when a generic firestore exception ocurrs',
        (WidgetTester tester) async {
      //Create necessary information for a user
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      //When createUser is called, throw an unexpected error
      when(mockUserRepository.createUser(username, email, password))
          .thenThrow(AppException('sign-up-error'));
      //Wait for sign up screen to laod
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter data to corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign up button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      //Expect to see error message for generic exception
      expect(
          find.textContaining(
              'Unable to complete registration. Please try again or contact support.'),
          findsOneWidget);
    });
    testWidgets('shows error when the password is weak',
        (WidgetTester tester) async {
      //Create necessary information for a user
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      //When createuser is called, throw weak-password
      when(mockUserRepository.createUser(username, email, password))
          .thenThrow(AppException('weak-password'));
      //Load sign up screen
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter data to necessary fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap signup button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      //Expect to see error for weak password
      expect(find.textContaining('Password must be at least 8 characters long and include numbers, letters, and special characters.'),
          findsOneWidget);
    });
    testWidgets('shows error when the email is taken',
        (WidgetTester tester) async {
      //Create necessary information for user
      const username = 'username';
      const email = 'taken@email.com';
      const password = '1';
      //When createuser is called, throw email-already-in-use
      when(mockUserRepository.createUser(username, email, password))
          .thenThrow(AppException('email-already-in-use'));
      //Load sign up screen
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign up button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      //Expect to see error message for email-already-in-use
      expect(
          find.textContaining(
              'This email is already associated with another account.'),
          findsOneWidget);
    });
    testWidgets('shows error when a generic firebase auth exception ocurrs',
        (WidgetTester tester) async {
      //Create necessary data for user
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      //When createuser is called throw an unexpected error
      when(mockUserRepository.createUser(username, email, password))
          .thenThrow(AppException('sign-up-error'));
      //load sign up screen
      final container = createProviderContainer();
      await tester.pumpWidget(createSignUpWidget(container));

      //Enter data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap sign up button
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      //Expect to see error message for general exception.
      expect(
          find.textContaining(
              'Unable to complete registration. Please try again or contact support.'),
          findsOneWidget);
    });
  });
}
