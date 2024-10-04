import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:senior_final_project/main.dart';
import 'package:senior_final_project/core/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ProviderContainer container;

  setUpAll(() async {
    await Firebase.initializeApp();
    setupEmulators(useEmulators: true);
  });

  tearDownAll(() {});

  setUp(() {
    container = ProviderContainer();
    container.read(authServicesProvider).signOut();
  });


  group('sign up flow', () {
    final usernameField = find.byKey(const Key('username-field'));
    final emailField = find.byKey(const Key('email-field'));
    final passwordField = find.byKey(const Key('password-field'));
    final signUpButton = find.byKey(const Key('signup-button'));

    Future<void> navigateToSignUpPage(WidgetTester tester) async {
      //Wait for app to load
      await tester.pumpWidget(const ProviderScope(
          child: MyApp(
        duration: Duration.zero,
      )));

      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Navigate to sign up screen by tapping sign up button on welcome screen
      expect(signUpButton, findsOneWidget);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      //Expect to see Sign Up title to verify we are on sign up screen
      expect(find.text('Sign Up'), findsAny);
    }

    testWidgets('User can sign up and reach home page', (tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter all necessary information to corresponding fields
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Grab the current authenticated user and check it matches our previous inputs
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);
      expect(user!.email, 'testuser@email.com');
      expect(user.uid, isNotEmpty);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Empty fields show error', (tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Tap sign up button without entering necessary data
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for empty fields
      expect(find.text('Please fill in all of the fields.'), findsOneWidget);
    });

    testWidgets('Invalid email format shows error', (tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but with an invalid email address
      await tester.enterText(usernameField, 'testUser2');
      await tester.enterText(emailField, 'invalidemail');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for invalid email address
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'The email provided is not a valid email address.'),
          findsOneWidget);
    });

    testWidgets('Already existing email shows error', (tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using an email that's taken (email was used on first test)
      await tester.enterText(usernameField, 'testUser3');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken email
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'This email is already associated with another account.'),
          findsOneWidget);
    });

    testWidgets('Username not unique shows error', (tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using a username that's taken (username was used on first test)
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken username
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'This username is already taken. Please try another one.'),
          findsOneWidget);
    });
  });

  group('log in flow', () {
    final emailField = find.byKey(const Key('email-field'));
    final passwordField = find.byKey(const Key('password-field'));
    final logInButton = find.byKey(const Key('login-button'));

    Future<void> navigateToLogInScreen(WidgetTester tester) async {
      //Wait for app to load
      await tester.pumpWidget(const ProviderScope(
          child: MyApp(
        duration: Duration.zero,
      )));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Navigate to log in screen by tapping log in button on welcome screen
      expect(logInButton, findsOneWidget);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();
      //Expect to see Sign In title to verify we are on Log in screen
      expect(find.text('Sign In'), findsAny);
    }

    testWidgets('User can log in  and reach home page', (tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter all necessary information to corresponding fields
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap log in button
      await tester.tap(logInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Grab the current authenticated user and check it matches our previous inputs
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);
      expect(user!.email, 'testuser@email.com');
      expect(user.uid, isNotEmpty);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Empty fields show error', (tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Tap log in button without entering necessary data
      await tester.tap(logInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for empty fields
      expect(find.text('Please fill in all of the fields.'), findsOneWidget);
    });

    testWidgets('Invalid email format shows error', (tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but with an invalid email address
      await tester.enterText(emailField, 'invalidemail');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap log in button
      await tester.tap(logInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for invalid email address
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'The email provided is not a valid email address.'),
          findsOneWidget);
    });

    testWidgets('Incorrect password shows error', (tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but using the incorrect password
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'incorrect');

      //Tap log in button
      await tester.tap(logInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for incorrect credentials
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'Your email address or password is incorrect.'),
          findsOneWidget);
    });

  });
}
