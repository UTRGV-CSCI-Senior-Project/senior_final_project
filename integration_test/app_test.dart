import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:senior_final_project/main.dart';
import 'package:senior_final_project/core/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
    setUpLocator(useEmulators: true);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('sign up flow', () {
    final usernameField = find.byKey(const Key('username-field'));
    final emailField = find.byKey(const Key('email-field'));
    final passwordField = find.byKey(const Key('password-field'));
    final signUpButton = find.byKey(const Key('signup-button'));

    Future<void> navigateToSignUpPage(WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(signUpButton, findsOneWidget);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      expect(find.text('Sign Up'), findsAny);
    }

    testWidgets('User can sign up and reach home page', (tester) async {
      await navigateToSignUpPage(tester);
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);
      expect(user!.email, 'testuser@email.com');
      expect(user.uid, isNotEmpty);
    });

    testWidgets('Empty fields show error', (tester) async {
      await navigateToSignUpPage(tester);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      expect(find.text('Please fill in all of the fields.'), findsOneWidget);
    });

    testWidgets('Invalid email format shows error', (tester) async {
      await navigateToSignUpPage(tester);
      await tester.enterText(usernameField, 'testUser2');
      await tester.enterText(emailField, 'invalidemail');
      await tester.enterText(passwordField, 'Pass123!');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      expect(find.text('The email provided is not a valid email address.'), findsOneWidget);
    });

    testWidgets('Already existing email shows error', (tester) async {
      await navigateToSignUpPage(tester);
      await tester.enterText(usernameField, 'testUser3');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      expect(find.text('This email is already associated with another account.'), findsOneWidget);
    });

    testWidgets('Username not unique shows error', (tester) async {
      await navigateToSignUpPage(tester);
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      expect(find.text('This username is already taken. Please try another one.'), findsOneWidget);
    });

  });
}
