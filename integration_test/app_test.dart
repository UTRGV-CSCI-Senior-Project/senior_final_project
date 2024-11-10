import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/home/profile_tab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:folio/main.dart';
import 'package:folio/core/service_locator.dart';

class MockImagePicker extends ImagePicker {
  @override
  Future<XFile?> pickImage(
      {required ImageSource source,
      double? maxWidth,
      double? maxHeight,
      int? imageQuality,
      CameraDevice preferredCameraDevice = CameraDevice.rear,
      bool requestFullMetadata = true}) async {
    // Load the asset bytes
    final byteData = await rootBundle.load('integration_test/assets/pfp.jpg');
    final bytes = byteData.buffer.asUint8List();

    // Create a temporary file and write the asset bytes to it
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/test_image.jpg');
    await tempFile.writeAsBytes(bytes);

    return XFile(tempFile.path);
  }

  @override
  Future<List<XFile>> pickMultiImage(
      {double? maxWidth,
      double? maxHeight,
      int? imageQuality,
      bool requestFullMetadata = true}) async {
    final imagePaths = [
      'integration_test/assets/folio1.jpg',
      'integration_test/assets/folio2.jpg', // Add paths to additional images
      'integration_test/assets/folio3.jpg',
      'integration_test/assets/folio4.jpg', // Add paths to additional images
      'integration_test/assets/folio5.jpg',
    ];

    final tempDir = Directory.systemTemp;
    List<XFile> xFiles = [];

    for (final path in imagePaths) {
      // Load each image's byte data
      final byteData = await rootBundle.load(path);
      final bytes = byteData.buffer.asUint8List();

      // Create a temporary file for each image
      final tempFile = File('${tempDir.path}/${path.split('/').last}');
      await tempFile.writeAsBytes(bytes);

      // Add the XFile to the list
      xFiles.add(XFile(tempFile.path));
    }

    return xFiles;
  }
}

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
  final imagePickerButton = find.byKey(const Key('image-picker-button'));
  final barberServiceButton = find.byKey(const Key('Barber-button'));
  final carDetailerServiceButton = find.byKey(const Key('Car Detailer-button'));
  final profileTabButton = find.byKey(const Key('profile-button'));
  final createPortfolioButton =
      find.byKey(const Key('create-portfolio-button'));
  final createPortfolioNextButton =
      find.byKey(const Key('portfolio-next-button'));
  final editServicesButton = find.byKey(const Key('edit-services-button'));
  final updateServicesButton = find.byKey(const Key('update-services-button'));
  final homeTabButton = find.byKey(const Key('home-button'));
  final speedDialButton = find.byKey(const Key('speeddial-button'));
  final editProfileButton = find.byKey(const Key('editprofile-button'));
  final updateProfileButton = find.byKey(const Key('update-button'));
  final settingsButton = find.byKey(const Key('settings-button'));
  final verifyPasswordField = find.byKey(const Key('password-verify-field'));
  final verifyPasswordButton = find.byKey(const Key('verify-password-button'));
  final dialogField = find.byKey(const Key('dialog-field'));
  final dialogButton = find.byKey(const Key('dialog-button'));
////////////////////////////////////////////////////////////////////////

//////////////////////// Set Up and Tear Down //////////////////////////

  setUpAll(() async {
    await Firebase.initializeApp();
    setupEmulators(useEmulators: true);

    final mockImagePicker = MockImagePicker();

    container = ProviderContainer(
        overrides: [imagePickerProvider.overrideWithValue(mockImagePicker)]);
    await container.read(authServicesProvider).signOut();
  });

  setUp(() {
    final mockImagePicker = MockImagePicker();

    container = ProviderContainer(
        overrides: [imagePickerProvider.overrideWithValue(mockImagePicker)]);
  });

  tearDown(() {
    container.dispose();
  });

////////////////////////////////////////////////////////////////////////

//////////////////////// Any Necessary Functions ////////////////////////

  Future<void> navigateToSignUpPage(WidgetTester tester) async {
    //Wait for app to load
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MyApp(
          duration: Duration.zero,
        )));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
        signUpButton, 500.0, // Scroll amount per attempt
        scrollable: scrollable.first);

    //Navigate to sign up screen by tapping sign up button on welcome screen
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToLogInScreen(WidgetTester tester) async {
    //Wait for app to load
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MyApp(
          duration: Duration.zero,
        )));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
        signInButton, 500.0, // Scroll amount per attempt
        scrollable: scrollable.first);

    //Navigate to log in screen by tapping log in button on welcome screen
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////
  group('Happy Paths', () {
    testWidgets(
        'As a new user, I can sign up, complete onboarding, and reach the home screen.',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data
      await tester.enterText(usernameField, 'testUser');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');

      FocusManager.instance.primaryFocus?.unfocus();

      //Tap sign up button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signUpButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Enter full name in onboarding screen and tap next
      await tester.enterText(fullNameField, "First Last");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Tap next on second onboarding screen
      expect(find.text('Select the services you\'re interested in.'),
          findsOneWidget);
      await tester.tap(barberServiceButton);
      await tester.tap(carDetailerServiceButton);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Expect to see home screen with user's full name
      expect(find.textContaining('First Last'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user that has not completed onboarding, I can sign in, complete onboarding, and reach the home screen',
        (WidgetTester tester) async {
      //Navigate to sign in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data and sign in
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');

      FocusManager.instance.primaryFocus?.unfocus();
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Fill in full name on onbording screen and proceed to 2nd screen
      expect(find.text('Name and Profile Picture'), findsOneWidget);
      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, "Second User");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Tap Done! on second onboarding screen
      expect(find.text('Select the services you\'re interested in.'),
          findsOneWidget);
      await tester.tap(barberServiceButton);
      await tester.tap(carDetailerServiceButton);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Expect to see home screen with user's full name
      expect(find.textContaining('Second User'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing normal user I can sign in, reach the home screen, and view my information in the profile screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Expect to see home screen with user's full name.
      expect(find.textContaining('Second User'), findsOneWidget);

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Second User'), findsOneWidget);
      expect(find.text('secondUser@email.com'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing professional user I can sign in and view my portfolio data in the profile screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'firstUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Expect to see home screen with user's full name.
      expect(find.textContaining('First User'), findsOneWidget);

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('First User'), findsOneWidget);
      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('Barber Portfolio'), findsOneWidget);
      expect(find.text('firstUser@email.com'), findsOneWidget);
      expect(find.byType(Image), findsExactly(6));
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in and update my preferred services from the home screen',
        (WidgetTester tester) async {
      await navigateToLogInScreen(tester);
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(signInButton, 500.0,
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(homeTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      // Verify initial services are displayed
      expect(find.text('BARBER'), findsOneWidget);
      expect(find.text('CAR DETAILER'), findsOneWidget);

      // Tap edit button to update services
      await tester.tap(editServicesButton);
      await tester.pumpAndSettle();

      // Verify we're on the update services screen
      expect(find.text('Update Your Interests!'), findsOneWidget);

      await tester.tap(find.text('Hair Stylist'));
      await tester.tap(find.text('Barber'));

      await tester.pumpAndSettle();

      // Update services
      await tester.tap(updateServicesButton);
      await tester.pumpAndSettle();

      // Verify new services are displayed
      expect(find.text('HAIR STYLIST'), findsOneWidget);
      expect(find.text('BARBER'), findsNothing);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in, go to the profile tab, and update my profile.',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(editProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(fullNameField, 'New Name');
      await tester.enterText(usernameField, 'newusername');

      final scrollable2 = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          updateProfileButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable2.first);
      await tester.tap(updateProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.textContaining('New Name'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and view my information.',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(find.text('New Name'), findsOneWidget);
      expect(find.text('newusername'), findsOneWidget);
      expect(find.text('testuser@email.com'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and change my password.',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('Password')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.enterText(verifyPasswordField, 'Pass123!');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Update Password'), findsOneWidget);
      await tester.enterText(dialogField, '123456');
      await tester.tap(dialogButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(EditProfile), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and change my email.',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('Email')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.enterText(verifyPasswordField, '123456');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Change Email'), findsOneWidget);
      await tester.enterText(dialogField, 'newemail@email.com');
      await tester.tap(dialogButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(EditProfile), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing normal user I can sign in, go to the profile tab and create a portfolio ',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Expect to see home screen with user's full name.
      expect(find.textContaining('Second User'), findsOneWidget);

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Second User'), findsOneWidget);
      expect(find.text('secondUser@email.com'), findsOneWidget);

      await tester.tap(createPortfolioButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(barberServiceButton);
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(imagePickerButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle(const Duration(seconds: 20));

      expect(find.text('Second User'), findsOneWidget);
      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('Barber Portfolio'), findsOneWidget);
      expect(find.text('secondUser@email.com'), findsOneWidget);
      expect(find.byType(Image), findsExactly(6));
      await container.read(authServicesProvider).signOut();
    });
    testWidgets(
        'As an existing professional user I can sign in, go to settings and manage my portfolio',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to settings screen
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      //Click on manage portfolio in settings
      await tester.tap(find.text('Manage portfolio'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);

      //Change service offered
      await tester.tap(find.text('Service'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.text('Car Detailer'));
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Settings'), findsOneWidget);

      //Update experience
      await tester.tap(find.text('Manage portfolio'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Experience'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '5');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Settings'), findsOneWidget);

      //Check information was updated
      await tester.tap(find.text('Manage portfolio'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Car Detailer'), findsOneWidget);
      expect(find.text('5 years'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing  user I can sign in, go to settings and report a bug',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'firstUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to settings screen
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      //Click on Report a bug in settings
      await tester.tap(find.text('Report a bug'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.enterText(
          find.byType(TextField).first, 'Reporting a bug subject line');
      await tester.enterText(find.byType(TextField).last,
          'This is the message box for reporting a  bug');
      await tester.tap(find.text('Submit Bug Report'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Thank you for reporting this bug!'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing  user I can sign in, go to settings and get help',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'firstUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to settings screen
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      //Click on Report a bug in settings
      await tester.tap(find.text('Get Help'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.enterText(
          find.byType(TextField).first, 'Getting help subject line');
      await tester.enterText(find.byType(TextField).last,
          'This is the message box for getting help');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('Your help request has been submitted!'), findsOneWidget);

      await container.read(authServicesProvider).signOut();
    });
  });

  /////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  group('Sad Paths', () {
    testWidgets(
        'As a new user, if I sign up with invalid email, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but with an invalid email address
      await tester.enterText(usernameField, 'testUser2');
      await tester.enterText(emailField, 'invalidemail');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();
      //Tap sign up button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signUpButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for invalid email address
      expect(
          find.textContaining(
              'The email provided is not a valid email address.'),
          findsOneWidget);
    });

    testWidgets(
        'As a new user, if I sign up with an existing email, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using an email that's taken (email was used on first test)
      await tester.enterText(usernameField, 'testUser3');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap sign up button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signUpButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken email
      expect(
          find.textContaining(
              'This email is already associated with another account.'),
          findsOneWidget);
    });

    testWidgets(
        'As a new user, if I sign up with a weak password, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using a username that's taken (username was used on first test)
      await tester.enterText(usernameField, 'weakUser');
      await tester.enterText(emailField, 'weakUser@email.com');
      await tester.enterText(passwordField, '1');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap sign up button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signUpButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken username
      expect(
          find.textContaining(
              'Password must be at least 8 characters long and include numbers, letters, and special characters.'),
          findsOneWidget);
    });

    testWidgets(
        'As a new user, if I sign up with a taken username, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToSignUpPage(tester);

      //Enter necessary data, but using a username that's taken (username was used on first test)
      await tester.enterText(usernameField, 'newusername');
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'Pass123!');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap sign up button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signUpButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //Expect to see error for taken username
      expect(
          find.textContaining(
              'This username is already taken. Please try a different one.'),
          findsOneWidget);
    });

    testWidgets(
        'As an existing user, if I sign in with an unexisting email, I see an error and stay on the sign in screen',
        (WidgetTester tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but using the an unexisting email
      await tester.enterText(emailField, 'testusernotexisting@email.com');
      await tester.enterText(passwordField, 'incorrect');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap log in button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Expect to see error for incorrect credentials
      expect(
          find.textContaining(
              'No account found with this email address. Please check the email or create a new account.'),
          findsOneWidget);
    });

    testWidgets(
        'As an existing user, if I sign in with the incorrect password, I see an error and stay on the sign in screen',
        (WidgetTester tester) async {
      //Navigate to log in screen
      await navigateToLogInScreen(tester);

      //Enter necessary data, but using the incorrect password
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, 'incorrect');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap log in button
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      //Expect to see error for incorrect credentials
      expect(
          find.textContaining(
              'Incorrect password. Please try again or reset your password.'),
          findsOneWidget);
    });

    testWidgets(
        'As a user updating services, I should see an error if I try to update with no services selected',
        (WidgetTester tester) async {
      await navigateToLogInScreen(tester);
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(signInButton, 500.0,
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(homeTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      // Tap edit button
      await tester.tap(editServicesButton);
      await tester.pumpAndSettle();

      // Deselect all services
      await tester.tap(find.text('Hair Stylist'));
      await tester.tap(carDetailerServiceButton);
      await tester.pumpAndSettle();

      // Try to update with no services selected
      await tester.tap(updateServicesButton);
      await tester.pumpAndSettle();

      // Expect to see error message
      expect(find.text('Please select at least one.'), findsOneWidget);

      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        "As a user completing the onboarding, if I dont't enter my name I should see an error, and if I don't select at least one service, I should see an error.",
        (WidgetTester tester) async {
      await navigateToLogInScreen(tester);

      //Enter necessary data and sign in
      await tester.enterText(emailField, 'thirdUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Tap next button without inputtting full name
      expect(find.text('Name and Profile Picture'), findsOneWidget);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Expect to see error
      expect(find.text('Please enter your full name.'), findsOneWidget);
      await tester.enterText(fullNameField, 'Third User');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Tap Done! on second onboarding screen without choosing service
      expect(find.text('Select the services you\'re interested in.'),
          findsOneWidget);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();

      //Expect to see error
      expect(find.text('Select at least one service.'), findsOneWidget);

      await tester.tap(barberServiceButton);
      await tester.tap(onboardingButton);
      await tester.pumpAndSettle();
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        "As a user trying to create a portfolio, I should see errors if I don't select a service or upload at least 5 images",
        (WidgetTester tester) async {
      await navigateToLogInScreen(tester);

      //Enter necessary data and sign in
      await tester.enterText(emailField, 'thirdUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to profile tab and click button to create a portfolio
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle();
      await tester.tap(createPortfolioButton);
      await tester.pumpAndSettle();

      //Tap next without selecting a service, expect to see an error for unselected service
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle();
      expect(find.text('Please select a service.'), findsOneWidget);

      //Select service to proceed to next screens
      await tester.tap(barberServiceButton);
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle();

      //Pass the experience screen without inputting years/months
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle();

      //Tap next button on image upload screen without uploading images
      await tester.tap(createPortfolioNextButton);
      await tester.pumpAndSettle();

      //Expect to see error messages for required images
      expect(find.text('Please upload at least 5 images.'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I can sign in, go to the profile tab, and I see an error if i update my profile with empty fields',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(editProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(fullNameField, '');
      await tester.enterText(usernameField, '');

      final scrollable2 = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          updateProfileButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable2.first);
      await tester.tap(updateProfileButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.textContaining('Please fill in all necessary fields.'),
          findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I cannot change my email if I enter incorrect verification password',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('Email')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter incorrect password for verification
      await tester.enterText(verifyPasswordField, 'wrongpassword');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Expect to see error message and not proceed to email change dialog
      expect(find.text('Change Email'), findsNothing);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing user, I cannot change my password if I enter incorrect verification password',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('Password')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Enter incorrect password for verification
      await tester.enterText(verifyPasswordField, 'wrongpassword');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Expect to see error message and not proceed to password change dialog
      expect(find.text('Update Password'), findsNothing);
      await container.read(authServicesProvider).signOut();
    });

    testWidgets(
        'As an existing professional user I can sign in, and should not be able to update my portfolio with a blank service',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to settings screen
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //Click on manage portfolio in settings
      await tester.tap(find.text('Manage portfolio'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Car Detailer'), findsOneWidget);
      expect(find.text('5 years'), findsOneWidget);

      //Change service offered
      await tester.tap(find.text('Service'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.text('Car Detailer').last);
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please choose the service you offer.'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });
    testWidgets(
        'As an existing  user I can sign in, should not be able to submit a bug report or help request with empty fields',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'firstUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      //Go to settings screen
      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      //Click on Report a bug in settings
      await tester.tap(find.text('Report a bug'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Submit Bug Report'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill in all fields'), findsOneWidget);
      await container.read(authServicesProvider).signOut();
    });
  });
  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  group('Delete Account & Portfolio', () {
    testWidgets(
        'As an existing user, I can sign in, go to the account settings and delete my account',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'testuser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('DELETE ACCOUNT'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.enterText(verifyPasswordField, '123456');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 20));

      expect(find.text('Discover Local Talent,'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets(
        'As an existing user, I can sign in, go to the portfolio settings and delete my portfolio',
        (WidgetTester tester) async {
      //Navigate to sign up screen
      await navigateToLogInScreen(tester);

      //Sign In with the correct credentials
      await tester.enterText(emailField, 'secondUser@email.com');
      await tester.enterText(passwordField, '123456');
      FocusManager.instance.primaryFocus?.unfocus();

      //Tap Sign In and wait
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
          signInButton, 500.0, // Scroll amount per attempt
          scrollable: scrollable.first);
      await tester.tap(signInButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Manage portfolio'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('DELETE PORTFOLIO'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.enterText(verifyPasswordField, '123456');
      await tester.scrollUntilVisible(verifyPasswordButton, 50);
      await tester.tap(verifyPasswordButton);
      await tester.pumpAndSettle(const Duration(seconds: 20));

      expect(find.text('Second User'), findsOneWidget);
      expect(find.text('Car Detailer'), findsNothing);
      await container.read(authServicesProvider).signOut();
    });
  });
}
