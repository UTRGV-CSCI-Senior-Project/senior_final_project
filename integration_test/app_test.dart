import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/views/home/profile_tab.dart';
import 'package:folio/widgets/chatroom_tile_widget.dart';
import 'package:folio/widgets/email_verification_dialog.dart';
import 'package:folio/widgets/message_tile_widget.dart';
import 'package:folio/widgets/sms_code_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:folio/main.dart';
import 'package:folio/core/service_locator.dart';
import 'package:http/http.dart' as http;

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
      int? limit,
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

 class MockLocationService extends LocationService {
  MockLocationService()
      : super(
          GeolocatorPlatform.instance,
          GeocodingService(),
        );

  final Position _mockPosition = Position(
    latitude: 37.7300,
    longitude: -122.4194,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  final String _mockAddress = "San Francisco, CA, USA";
  final String _mockCity = "San Francisco";

  @override
  Future<bool> checkService() async {
    return true;
  }

  @override
  Future<bool> checkPermission() async {
    return true;
  }

  @override
  Future<Position> getCurrentLocation() async {
    return _mockPosition;
  }

  @override
  Future<List<double>> getCurrentLatiLong() async {
    return [_mockPosition.latitude, _mockPosition.longitude];
  }

  @override
  Future<String> getAddress(double latitude, double longitude) async {
    return _mockAddress;
  }

  @override
  Future<String> getCity(double latitude, double longitude) async {
    return _mockCity;
  }

  @override
  Stream<Position> getPositionStream() {
    return Stream<Position>.value(_mockPosition);
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
  final feedbackButton = find.byKey(const Key('submit-feedback-button'));
  final noVerificationButton = find.byKey(const Key('no-verification-button'));
  final inboxTabButton = find.byKey(const Key('inbox-button'));
  final discoverTabButton = find.byKey(const Key('discover-button'));
  final discoverTextField = find.byKey(const Key('discover-field'));
  final removeRadiusButton = find.byKey(const Key('remove-radius'));

////////////////////////////////////////////////////////////////////////

//////////////////////// Set Up and Tear Down //////////////////////////

  setUpAll(() async {
    await Firebase.initializeApp();
    setupEmulators(useEmulators: true);
    dotenv.load(fileName: '.env');
    final mockImagePicker = MockImagePicker();
    final mockLocationService = MockLocationService();
    container = ProviderContainer(
        overrides: [imagePickerProvider.overrideWithValue(mockImagePicker),
        locationServiceProvider.overrideWithValue(mockLocationService)
        ]);
    await container.read(authServicesProvider).signOut();
  });

  setUp(() {
    final mockImagePicker = MockImagePicker();
    final mockLocationService = MockLocationService();

    container = ProviderContainer(
        overrides: [imagePickerProvider.overrideWithValue(mockImagePicker),
        locationServiceProvider.overrideWithValue(mockLocationService)
        ]);
  });

  tearDown(() {
    container.read(userRepositoryProvider).signOut();
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
    await tester.pumpAndSettle(const Duration(seconds: 4));
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
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  Future<String?> getLatestVerificationCode() async {
    final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    try {
      final response = await http.get(
        Uri.parse(
            'http://$host:9099/emulator/v1/projects/senior-final-project/verificationCodes'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> codes = data['verificationCodes'] as List<dynamic>;

        if (codes.isNotEmpty) {
          return codes.first['code'] as String;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////
  group('Happy Paths', () {
  
    testWidgets(
        'As a new user, I can sign up, complete onboarding, reach the home screen, and view a near by portfolio',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 8));
        //Expect to see home screen with user's full name

        expect(find.textContaining('First Last'), findsOneWidget);
        expect(find.text('First User'), findsOneWidget);
        expect(find.text('Beginner'), findsOneWidget);
        expect(find.text('6 mi away'), findsOneWidget);

        await tester.tap(find.byKey(const Key('view-portfolio-button')).first);
        await tester.pumpAndSettle(const Duration(seconds: 8));
        expect(find.text('First User'), findsOneWidget);
        expect(find.text('6 miles away'), findsOneWidget);
        expect(find.byType(Image), findsExactly(6));
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user that has not completed onboarding, I can sign in, complete onboarding, and reach the home screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
    });

    testWidgets(
        'As an existing user I can sign in, go to the discover tab, and search and filter portfolios',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(discoverTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('First User'), findsOneWidget);
        expect(find.text('6 mi away'), findsOneWidget);

        await tester.enterText(discoverTextField, 'Someone to cut my hair');
        await tester.pumpAndSettle(const Duration(seconds: 15));

        expect(find.text('First User'), findsOneWidget);
        expect(find.text('6 mi away'), findsOneWidget);
        expect(find.text('Barber'), findsOneWidget);

        await tester.tap(find.byKey(const Key('filter-button')));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.scrollUntilVisible(removeRadiusButton, 50, scrollable: find.byType(Scrollable).last);
        await tester.tap(removeRadiusButton);
        await tester.tap(removeRadiusButton);
        await tester.tap(removeRadiusButton);
        await tester.tap(removeRadiusButton);
        await tester.tap(removeRadiusButton);
        await tester.tap(find.byKey(const Key('apply-filters-button')));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        expect(find.text('No portfolios matched your selected filters.'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing normal user I can sign in, reach the home screen, and view my information in the profile screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
    });

    testWidgets(
        'As an existing professional user I can sign in and view my portfolio data in the profile screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        expect(find.textContaining('First User'), findsExactly(2));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('First User'), findsOneWidget);
        expect(find.text('Barber'), findsOneWidget);
        expect(find.text('Barber Portfolio'), findsOneWidget);
        expect(find.text('firstUser@email.com'), findsOneWidget);
        expect(find.byType(Image), findsExactly(6));
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in and update my preferred services from the home screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Verify we're on the update services screen
        expect(find.text('Update Your Interests!'), findsOneWidget);

        await tester.tap(find.text('Hair Stylist'));
        await tester.tap(find.text('Barber'));

        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Update services
        await tester.tap(updateServicesButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Verify new services are displayed
        expect(find.text('HAIR STYLIST'), findsOneWidget);
        expect(find.text('BARBER'), findsNothing);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the profile tab, and update my profile.',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(editProfileButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(fullNameField);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await tester
            .sendKeyEvent(LogicalKeyboardKey.backspace); // Clear existing text
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.enterText(fullNameField, 'New Name');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(usernameField);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await tester
            .sendKeyEvent(LogicalKeyboardKey.backspace); // Clear existing text
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.enterText(usernameField, 'newusername');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Ensure the button is visible before tapping
        await tester.tap(updateProfileButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.textContaining('New Name'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and view my information.',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        expect(find.text('New Name'), findsOneWidget);
        expect(find.text('newusername'), findsOneWidget);
        expect(find.text('testuser@email.com'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and change my password.',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(find.byKey(const Key('Password')));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.enterText(verifyPasswordField, 'Pass123!');
        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Update Password'), findsOneWidget);
        await tester.enterText(dialogField, '123456');
        await tester.tap(dialogButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(EditProfile), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and change my email.',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(find.byKey(const Key('Email')));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.enterText(verifyPasswordField, '123456');
        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Change Email'), findsOneWidget);
        await tester.enterText(dialogField, 'newemail@email.com');
        await tester.tap(dialogButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.byType(EditProfile), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing normal user I can sign in, go to the profile tab and create a portfolio ',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Become a professional'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Choose service
        await tester.tap(barberServiceButton);
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        //Leave experience blank
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        //Add images
        await tester.tap(imagePickerButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        //Leave details blank
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        //Enter address
        await tester.enterText(find.byType(AddressAutocompleteTextField), '123 Main Street, San Francisco');
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(createPortfolioNextButton);


        await tester.pumpAndSettle(const Duration(seconds: 40));
        await tester.tap(find.byKey(const Key('settings-back-button')));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.text('Second User'), findsOneWidget);
        expect(find.text('Barber'), findsOneWidget);
        expect(find.text('Barber Portfolio'), findsOneWidget);
        expect(find.text('secondUser@email.com'), findsOneWidget);
        expect(find.byType(Image), findsExactly(6));
        await container.read(authServicesProvider).signOut();
      });
    });
    testWidgets(
        'As an existing professional user I can sign in, go to settings and manage my portfolio',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Click on manage portfolio in settings
        await tester.tap(find.text('Manage portfolio'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Experience'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.enterText(find.byType(TextField).first, '5');
        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Settings'), findsOneWidget);

        //Check information was updated
        await tester.tap(find.text('Manage portfolio'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.text('Car Detailer'), findsOneWidget);
        expect(find.text('5 years'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing  user I can sign in, go to settings and report a bug',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Click on Report a bug in settings
        await tester.tap(find.text('Report a bug'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.enterText(
            find.byType(TextField).first, 'Reporting a bug subject line');
        await tester.enterText(find.byType(TextField).last,
            'This is the message box for reporting a  bug');
        await tester.tap(feedbackButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Settings'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing  user I can sign in, go to settings and get help',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Click on Report a bug in settings
        await tester.scrollUntilVisible(find.text('Get Help'), 50);
        await tester.tap(find.text('Get Help'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.enterText(
            find.byType(TextField).first, 'Getting help subject line');
        await tester.enterText(find.byType(TextField).last,
            'This is the message box for getting help');
        await tester.tap(feedbackButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Settings'), findsOneWidget);

        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the account settings and add my phone number',
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

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      await tester.tap(find.byKey(const Key('Phone Number')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      await tester.enterText(verifyPasswordField, '123456');
      await tester.tap(verifyPasswordButton);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Add your phone number'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '5555550000');
      await tester.tap(find.byKey(const Key('send-code-button')));
      await tester.pump(const Duration(seconds: 10));

      final code = await getLatestVerificationCode();

      expect(find.byType(SmsCodeDialog), findsOneWidget);
      await tester.enterText(find.byKey(const Key('pinput-field')), code ?? '');
      await tester.pump(const Duration(seconds: 5));
      await tester.tap(find.byKey(const Key('submit-sms-button')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

        expect(find.text('+15555550000'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });

      testWidgets(
        'As an existing user I can sign in, go to the inbox tab, see my existing message threads, and send a message',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        //Navigate to sign up screen
        await navigateToLogInScreen(tester);

        //Sign In with the correct credentials
        await tester.enterText(emailField, 'fourthUser@email.com');
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
        expect(find.textContaining('Fourth User'), findsOneWidget);

        await tester.tap(inboxTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('First User'), findsOneWidget);

        await tester.tap(find.byType(ChatRoomTile));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(find.text('Hello, I like your work!'), findsOneWidget);
        await tester.enterText(find.byKey(const Key('message-field')), 'Do you have any appointments soon?');
        await tester.tap(find.byKey(const Key('send-message-button')));
        await tester.pumpAndSettle(const Duration(seconds: 10));
        expect(find.byType(MessageTile), findsExactly(2));
        await container.read(authServicesProvider).signOut();
      });
    });
  });

  /////////////////////////////////////////////// HAPPY PATHS //////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  group('Sad Paths', () {
    testWidgets(
        'As a new user, if I sign up with invalid email, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Expect to see error for invalid email address
        expect(
            find.textContaining(
                'The email provided is not a valid email address.'),
            findsOneWidget);
      });
    });

    testWidgets(
        'As a new user, if I sign up with an existing email, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Expect to see error for taken email
        expect(
            find.textContaining(
                'This email is already associated with another account.'),
            findsOneWidget);
      });
    });

    testWidgets(
        'As a new user, if I sign up with a weak password, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Expect to see error for taken username
        expect(
            find.textContaining(
                'Password must be at least 8 characters long and include numbers, letters, and special characters.'),
            findsOneWidget);
      });
    });

    testWidgets(
        'As a new user, if I sign up with a taken username, I see an error and stay on the sign up screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Expect to see error for taken username
        expect(
            find.textContaining(
                'This username is already taken. Please try a different one.'),
            findsOneWidget);
      });
    });

    testWidgets(
        'As an existing user, if I sign in with an unexisting email, I see an error and stay on the sign in screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
    });

    testWidgets(
        'As an existing user, if I sign in with the incorrect password, I see an error and stay on the sign in screen',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
    });

    testWidgets(
        'As a user updating services, I should see an error if I try to update with no services selected',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        // Tap edit button
        await tester.tap(editServicesButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Deselect all services
        await tester.tap(find.text('Hair Stylist'));
        await tester.tap(carDetailerServiceButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Try to update with no services selected
        await tester.tap(updateServicesButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Expect to see error message
        expect(find.text('Please select at least one.'), findsOneWidget);

        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        "As a user completing the onboarding, if I dont't enter my name I should see an error, and if I don't select at least one service, I should see an error.",
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Expect to see error
        expect(find.text('Please enter your full name.'), findsOneWidget);
        await tester.enterText(fullNameField, 'Third User');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.tap(onboardingButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Tap Done! on second onboarding screen without choosing service
        expect(find.text('Select the services you\'re interested in.'),
            findsOneWidget);
        await tester.tap(onboardingButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Expect to see error
        expect(find.text('Select at least one service.'), findsOneWidget);

        await tester.tap(barberServiceButton);
        await tester.tap(onboardingButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        "As a user trying to create a portfolio, I should see errors if I don't select a service, upload at least 5 images, or add a location",
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Become a professional'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Tap next without selecting a service, expect to see an error for unselected service
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.text('Please select a service.'), findsOneWidget);

        //Select service to proceed to next screens
        await tester.tap(barberServiceButton);
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Pass the experience screen without inputting years/months
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Tap next button on image upload screen without uploading images
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Expect to see error messages for required images
        expect(find.text('Please upload at least 5 images.'), findsOneWidget);//Add images
        await tester.tap(imagePickerButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        //Leave details blank
        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        await tester.tap(createPortfolioNextButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.text("Please provide your business's location to proceed."), findsOneWidget);

        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the profile tab, and I see an error if i update my profile with empty fields',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(editProfileButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(fullNameField);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await tester
            .sendKeyEvent(LogicalKeyboardKey.backspace); // Clear existing text
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.enterText(fullNameField, '');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(usernameField);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await tester
            .sendKeyEvent(LogicalKeyboardKey.backspace); // Clear existing text
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.enterText(usernameField, '');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(updateProfileButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        expect(find.textContaining('Please fill in all necessary fields.'),
            findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I cannot change my email if I enter incorrect verification password',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(find.byKey(const Key('Email')));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Enter incorrect password for verification
        await tester.enterText(verifyPasswordField, 'wrongpassword');

        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Expect to see error message and not proceed to email change dialog
        expect(find.text('Change Email'), findsNothing);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I cannot change my password if I enter incorrect verification password',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        await tester.tap(find.byKey(const Key('Password')));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Enter incorrect password for verification
        await tester.enterText(verifyPasswordField, 'wrongpassword');
        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Expect to see error message and not proceed to password change dialog
        expect(find.text('Update Password'), findsNothing);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing professional user I can sign in, and should not be able to update my portfolio with a blank service',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));

        //Click on manage portfolio in settings
        await tester.tap(find.text('Manage portfolio'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.text('Car Detailer'), findsOneWidget);
        expect(find.text('5 years'), findsOneWidget);

        //Change service offered
        await tester.tap(find.text('Service'));
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(find.text('Car Detailer').last);
        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle(const Duration(seconds: 4));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
            find.text('Please choose the service you offer.'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });
    testWidgets(
        'As an existing  user I can sign in, should not be able to submit a bug report or help request with empty fields',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        //Click on Report a bug in settings
        await tester.scrollUntilVisible(find.text('Report a bug'), 50);
        await tester.tap(find.text('Report a bug'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Submit Bug Report'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Please fill in all fields'), findsOneWidget);
        await container.read(authServicesProvider).signOut();
      });
    });

    testWidgets(
        'As an existing user, I should not be able to add a phone number if my email is not verified',
        (WidgetTester tester) async {
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

      await tester.tap(noVerificationButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(profileTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(speedDialButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      await tester.tap(find.byKey(const Key('Phone Number')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(EmailVerificationDialog), findsOneWidget);
      expect(
          find.text(
              'Your email address needs to be verified before adding a phone number. Would you like to us to send a verification link to your email?'),
          findsOneWidget);
    });
  });
  /////////////////////////////////////////////// SAD PATHS ////////////////////////////////////////////////////////////////////////

  group('Delete Account & Portfolio', () {
    testWidgets(
        'As an existing user, I can sign in, go to the account settings and delete my account',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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

        await tester.tap(noVerificationButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(profileTabButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await tester.tap(speedDialButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('DELETE ACCOUNT'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('DELETE'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.enterText(verifyPasswordField, '123456');
        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 40));

        expect(find.text('Discover Local Talent,'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
      });
    });

    testWidgets(
        'As an existing user, I can sign in, go to the portfolio settings and delete my portfolio',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
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
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('Manage portfolio'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('DELETE PORTFOLIO'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.tap(find.text('DELETE'));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await tester.enterText(verifyPasswordField, '123456');
        await tester.tap(verifyPasswordButton);
        await tester.pumpAndSettle(const Duration(seconds: 40));

        expect(find.text('Second User'), findsOneWidget);
        expect(find.text('Car Detailer'), findsNothing);
        await container.read(authServicesProvider).signOut();
      });
    });
  });
  /*
  group('ChooseService Integration Tests', () {
    testWidgets('Test 1: No service selected does not proceed to next screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp()); // Replace MyApp with your main widget
      await tester.pumpAndSettle();

      // Find the button to go to the next screen
      final nextButton = find.byKey(
          Key('Servicenext-button')); // Change to your actual next button key

      // Tap the next button
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify that we are still on the current screen (e.g., check for the presence of the service selection)
      expect(find.byType(ChooseService), findsOneWidget);
    });

    testWidgets('Test 2: Select a service goes to next screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Select a service
      final serviceOption = find
          .byKey(Key('service-button-0')); // Adjust to the first service's key
      await tester.tap(serviceOption);
      await tester.pumpAndSettle();

      // Find and tap the next button
      final nextButton = find.byKey(Key('next-button'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify we are on the next screen
      expect(find.text('Next Screen'),
          findsOneWidget); // Change to whatever identifies the next screen
    });

    testWidgets('Test 3: Selecting a second service unmarks the first',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Select the first service
      final firstService = find.byKey(Key('service-button-0'));
      await tester.tap(firstService);
      await tester.pumpAndSettle();

      // Select the second service
      final secondService = find.byKey(Key('service-button-1'));
      await tester.tap(secondService);
      await tester.pumpAndSettle();

      // Check that the first service is unselected
      expect(
          find
              .byKey(Key('service-button-0'))
              .evaluate()
              .first
              .widget
              .isSelected,
          isFalse);
      expect(
          find
              .byKey(Key('service-button-1'))
              .evaluate()
              .first
              .widget
              .isSelected,
          isTrue);
    });

    testWidgets(
        'Test 4: Passes correct String and boolean value to next screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Select a service
      final serviceOption = find.byKey(Key('service-button-0'));
      await tester.tap(serviceOption);
      await tester.pumpAndSettle();

      // Find and tap the next button
      final nextButton = find.byKey(Key('next-button'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify the values passed to the next screen
      expect(find.text('Service Name'),
          findsOneWidget); // Adjust based on how you display the service name
      expect(find.byKey(Key('boolean-value-key')),
          findsOneWidget); // Adjust based on your boolean value's key
    });
  });
  */
}
