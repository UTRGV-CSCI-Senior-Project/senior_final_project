import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:folio/main.dart';
import 'package:folio/core/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

//////////////////////// Any Necessary Finders ////////////////////////

  final usernameField = find.byKey(const Key('username-field'));
  final emailField = find.byKey(const Key('email-field'));
  final passwordField = find.byKey(const Key('password-field'));
  final signUpButton = find.byKey(const Key('signup-button'));
  final fullNameField = find.byKey(const Key('name-field'));
  final onboardingButton = find.byKey(const Key('onboarding-button'));
  final signInButton = find.byKey(const Key('signin-button'));

////////////////////////////////////////////////////////////////////////


//////////////////////// Set Up and Tear Down //////////////////////////

  setUpAll(() async {
    await Firebase.initializeApp();
    setupEmulators(useEmulators: true);
  });

  tearDownAll(() {});

  setUp(() {
    container = ProviderContainer();
    container.read(authServicesProvider).signOut();
  });

////////////////////////////////////////////////////////////////////////


//////////////////////// Any Necessary Functions ////////////////////////

  Future<void> signUpUser(WidgetTester tester, String username, String password) async {
     //Wait for app to load
    await tester.pumpWidget(const ProviderScope(
        child: MyApp(
      duration: Duration.zero,
    )));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    //Navigate to sign up screen
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    //Enter necessary data
    await tester.enterText(usernameField, username);
    await tester.enterText(emailField, '$username@email.com');
    await tester.enterText(passwordField, password);

    //Tap sign up button
    await tester.tap(signUpButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

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

  Future<void> navigateToLogInScreen(WidgetTester tester) async {
    //Wait for app to load
    await tester.pumpWidget(const ProviderScope(
        child: MyApp(
      duration: Duration.zero,
    )));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    //Navigate to log in screen by tapping log in button on welcome screen
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    //Expect to see Sign In title to verify we are on Log in screen
    expect(find.text('Sign In'), findsAny);
  }
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////
  group('Happy Paths', () {
    testWidgets('As a new user, I can sign up, complete onboarding, and reach the home screen.',(WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Enter full name in onboarding screen and tap next
      await tester.enterText(fullNameField, "First Last");
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Tap next on second onboarding screen
      expect(find.text('What professions are you interested in?'), findsOneWidget);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();
      
      //Expect to see home screen with user's full name
      expect(find.text('Welcome, First Last!'), findsOneWidget);
    });

    testWidgets('As an existing user that has not completed onboarding, I can sign in, complete onboarding, and reach the home screen',(WidgetTester tester) async {
      //Sign up a new user and sign them out without completing onboarding
      await signUpUser(tester, 'newUser', 'pass123');
      await container.read(authServicesProvider).signOut();
      await tester.pumpAndSettle();
      expect(find.text('FOLIO'), findsOneWidget);

      //Navigate to sign in screen
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      //Enter necessary data and sign in
      await tester.enterText(emailField, 'newUser@email.com');
      await tester.enterText(passwordField, 'pass123');
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Fill in full name on onbording screen and proceed to 2nd screen
      expect(find.text('Name and Profile Picture'), findsOneWidget);
      await tester.enterText(fullNameField, "New User");
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Tap Done! on second onboarding screen
      expect(
          find.text('What professions are you interested in?'), findsOneWidget);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Expect to see home screen with user's full name
      expect(find.text('Welcome, New User!'), findsOneWidget);
    });

    testWidgets('As an existing user I can sign in and reach the home screen',(WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'newUser@email.com');
      await tester.enterText(passwordField, 'pass123');

      //Tap Sign In and wait
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Expect to see home screen with user's full name.
      expect(find.text('Welcome, New User!'), findsOneWidget);
    });
  });

  /////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  group('Sad Paths', () {
    testWidgets('As a new user, if I sign up with invalid email, I see an error and stay on the sign up screen',(WidgetTester tester) async {
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
      expect(find.textContaining('The email provided is not a valid email address.'),findsOneWidget);
    });

    testWidgets('As a new user, if I sign up with an existing email, I see an error and stay on the sign up screen',(WidgetTester tester) async {
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
      expect(find.textContaining('This email is already associated with another account.'),findsOneWidget);
    });

    testWidgets('As a new user, if I sign up with a weak password, I see an error and stay on the sign up screen',(WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using a username that's taken (username was used on first test)
      await tester.enterText(usernameField, 'weakUser');
      await tester.enterText(emailField, 'weakUser@email.com');
      await tester.enterText(passwordField, '1');

      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken username
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('The password provided is too weak.'),findsOneWidget);
    });

    testWidgets('As a new user, if I sign up with a taken username, I see an error and stay on the sign up screen',(WidgetTester tester) async {
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
      expect(find.textContaining('This username is already taken. Please try another one.'),findsOneWidget);
    });

    testWidgets('As an existing user, if I sign in with an unexisting email, I see an error and stay on the sign in screen', (WidgetTester tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but using the incorrect password
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'incorrect');

      //Tap log in button
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for incorrect credentials
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Your email address or password is incorrect.'), findsOneWidget);
    });

    testWidgets('As an existing user, if I sign in with the incorrect password, I see an error and stay on the sign in screen', (WidgetTester tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but using the incorrect password
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'incorrect');

      //Tap log in button
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for incorrect credentials
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Your email address or password is incorrect.'),findsOneWidget);
    });

  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  });
}
