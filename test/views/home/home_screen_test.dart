import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/loading_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/onboarding_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:folio/widgets/email_verification_dialog.dart';
import 'package:folio/widgets/portfolio_card.dart';
import 'package:folio/widgets/portfolio_list_item.dart';
import 'package:folio/widgets/request_location_dialog.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/login_screen_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';
import '../../mocks/home_screen_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockFirestoreServices mockFirestoreServices;
  late MockCloudMessagingServices mockCloudMessagingServices;
  late MockLocationService mockLocationService;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockFirestoreServices = MockFirestoreServices();
    mockCloudMessagingServices = MockCloudMessagingServices();
    mockLocationService = MockLocationService();
    when(mockFirestoreServices.getServices()).thenAnswer((_) async => [
          'Nail Tech',
          'Barber',
          'Tattoo Artist',
          'Car Detailer',
          'Hair Stylist'
        ]);
    when(mockCloudMessagingServices.initNotifications())
        .thenAnswer((_) async => {});
  });

  ProviderContainer createProviderContainer(
      {UserModel? userModel,
      PortfolioModel? portfolioModel,
      List<ChatroomModel>? chatroomModel}) {
    return ProviderContainer(
      overrides: [
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        userDataStreamProvider.overrideWith((ref) =>
            Stream.value({'user': userModel, 'portfolio': portfolioModel})),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        cloudMessagingServicesProvider
            .overrideWithValue(mockCloudMessagingServices),
        chatroomStreamProvider.overrideWith((ref) => chatroomModel != null
            ? Stream.value(chatroomModel)
            : Stream.value([])),
        locationServiceProvider.overrideWithValue(mockLocationService),
        nearbyPortfoliosProvider.overrideWith((ref) => [
              PortfolioModel(
                  service: 'Barber',
                  details: 'Im a barber',
                  years: 3,
                  months: 1,
                  uid: 'test-uid',
                  address: '1234s Street',
                  latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
                  professionalsName: 'Barber User',
                  nameArray: ['Barber', 'User']),
              PortfolioModel(
                  service: 'Nail Tech',
                  details: 'Im a nail tech',
                  years:6,
                  months: 1,
                  uid: 'test-uid',
                  address: '1234s Street',
                  latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
                  professionalsName: 'Nail User',
                  nameArray: ['Nail', 'User'])
            ]),
            servicesStreamProvider.overrideWith((ref){
              return Stream.value([
          'Nail Tech',
          'Barber',
          'Tattoo Artist',
          'Car Detailer',
          'Hair Stylist'
        ]);
            })
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
      container.dispose();
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
      container.dispose();
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
        isEmailVerified: true,
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      // Check if the app bar shows correct welcome message
      expect(find.textContaining('Welcome, Test User!'), findsOneWidget);

      // Verify navigation bar is present with all items
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      container.dispose();
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
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      // Tap discover tab
      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Discover'), findsExactly(2));

      // Tap inbox tab
      await tester.tap(find.byIcon(Icons.email_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Inbox'), findsExactly(2));

      // Tap profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsExactly(2));
      container.dispose();
    });

    testWidgets('shows loading screen when stream is loading',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          userDataStreamProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
          firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          cloudMessagingServicesProvider
              .overrideWithValue(mockCloudMessagingServices),
          chatroomStreamProvider.overrideWith((ref) => const Stream.empty())
        ],
      );

      await tester.pumpWidget(createHomeScreen(container));
      expect(find.byType(LoadingScreen), findsOneWidget);
      container.dispose();
    });

    testWidgets('shows email verification dialog when email is not verified',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: false, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(EmailVerificationDialog), findsOneWidget);
      container.dispose();
    });

    testWidgets('doesnt show email verification dialog when email is  verified',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: true, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(EmailVerificationDialog), findsNothing);
      container.dispose();
    });

    testWidgets('shows email verification dialog when email is not verified',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: false, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(EmailVerificationDialog), findsOneWidget);
    });

    testWidgets('doesnt show email verification dialog when email is  verified',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: true, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.byType(EmailVerificationDialog), findsNothing);
    });
  });

  group('home tab', () {
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
      await tester.tap(find.text('No'));
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
      container.dispose();
    });

    testWidgets('shows nearby portfolios', (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: true, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Near You'), findsOneWidget);
      expect(find.byType(PortfolioCard), findsExactly(2));
      expect(find.text('Barber User'), findsOneWidget);
      expect(find.text('Nail User'), findsOneWidget);
    });
  });

  group('profile tab', () {
    testWidgets('can edit user information from profile tab',
        (WidgetTester tester) async {
      final userModel = UserModel(
          uid: 'testuid',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false,
          fullName: 'Test User',
          completedOnboarding: true,
          profilePictureUrl: 'url');
      when(mockFirestoreServices.isUsernameUnique(any))
          .thenAnswer((_) => Future.value(true));
      when(mockUserRepository.updateProfile(profilePicture: null, fields: {
        'fullName': 'New Name',
        'username': 'newusername',
        'profilePictureUrl': null
      })).thenAnswer((_) async {});

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsExactly(2));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.enterText(find.byKey(const Key('name-field')), 'New Name');
      await tester.enterText(
          find.byKey(const Key('username-field')), 'newusername');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('update-button')));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      verify(mockUserRepository.updateProfile(profilePicture: null, fields: {
        'fullName': 'New Name',
        'username': 'newusername',
        'profilePictureUrl': null
      })).called(1);
      container.dispose();
    });

    testWidgets('shows speed dial menu on profile tab',
        (WidgetTester tester) async {
      final userModel = UserModel(
          uid: 'testuid',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false,
          fullName: 'Test User',
          completedOnboarding: true,
          profilePictureUrl: 'url');
      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      // Navigate to profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Verify speed dial exists
      expect(find.byKey(const Key('speeddial-button')), findsOneWidget);

      // Open speed dial menu
      await tester.tap(find.byKey(const Key('speeddial-button')));
      await tester.pumpAndSettle();

      // Verify menu items
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Share Profile'), findsOneWidget);
      container.dispose();
    });
  });

  group('inbox tab', () {
    testWidgets('can navigate to inbox tab and see chatrooms',
        (WidgetTester tester) async {
      final userModel = UserModel(
          uid: 'user2',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false,
          fullName: 'Test User',
          completedOnboarding: true,
          isEmailVerified: true,
          profilePictureUrl: 'url');
      final chatrooms = [
        ChatroomModel(
            id: 'user1_user2',
            participants: [
              ChatParticipant(uid: 'user1', identifier: 'User One'),
              ChatParticipant(uid: 'user2', identifier: 'User Two')
            ],
            lastMessage: MessageModel(
                senderId: 'user1',
                recieverId: 'user2',
                message: 'Hello',
                timestamp: DateTime.now()),
            participantIds: ['user1', 'user2']),
        ChatroomModel(
            id: 'user2_user3',
            participants: [
              ChatParticipant(uid: 'user2', identifier: 'User Two'),
              ChatParticipant(uid: 'user3', identifier: 'User Three')
            ],
            lastMessage: MessageModel(
                senderId: 'user3',
                recieverId: 'user2',
                message: 'Whats up',
                timestamp: DateTime.now()),
            participantIds: ['user2', 'user3']),
      ];
      final container = createProviderContainer(
          userModel: userModel, chatroomModel: chatrooms);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.email_outlined));
      await tester.pumpAndSettle();

      // Verify speed dial exists
      expect(find.text('Inbox'), findsExactly(2));
      expect(find.text('Messages'), findsOneWidget);

      //Expect two chatrooms to show with other participant's name
      expect(find.text("User One"), findsOneWidget);
      expect(find.text('User Three'), findsOneWidget);
    });
  });

  group('discover tab', (){
    testWidgets('shows nearby portfolios when discover tab is opened', (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        preferredServices: ['Nail Tech', 'Hair Stylist'],
        isEmailVerified: true, // Set email as not verified
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('discover-button')));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Discover'), findsAny);
      expect(find.byType(PortfolioListItem), findsExactly(2));
      expect(find.text('Barber User'), findsOneWidget);
      expect(find.text('Nail User'), findsOneWidget);
    });
  });

  group('Location Permission', () {
    testWidgets('shows location permission dialog when not granted',
        (WidgetTester tester) async {
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => false);

      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
      );

      final container = ProviderContainer(
        overrides: [
          userDataStreamProvider
              .overrideWith((ref) => Stream.value({'user': userModel})),
          locationServiceProvider.overrideWithValue(mockLocationService),
          hasShownLocationPermissionDialog.overrideWith((ref) => false),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RequestLocationDialog), findsOneWidget);
    });

    testWidgets('does not show location dialog if already shown',
        (WidgetTester tester) async {
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => false);

      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
      );

      final container = ProviderContainer(
        overrides: [
          userDataStreamProvider
              .overrideWith((ref) => Stream.value({'user': userModel})),
          locationServiceProvider.overrideWithValue(mockLocationService),
          hasShownLocationPermissionDialog.overrideWith((ref) => true),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RequestLocationDialog), findsNothing);
    });
  });

  group('Messaging Initialization', () {
    testWidgets('handles messaging initialization error',
        (WidgetTester tester) async {
      when(mockCloudMessagingServices.initNotifications())
          .thenThrow(Exception('Messaging init failed'));

      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
      );

      final container = ProviderContainer(
        overrides: [
          userDataStreamProvider
              .overrideWith((ref) => Stream.value({'user': userModel})),
          cloudMessagingServicesProvider
              .overrideWithValue(mockCloudMessagingServices),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app still loads without crashing
      expect(find.text('Welcome, Test User!'), findsOneWidget);
    });
  });

  group('Speed Dial Menu', () {
    testWidgets('opens settings screen from speed dial',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Navigate to profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Open speed dial
      await tester.tap(find.byKey(const Key('speeddial-button')));
      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings screen is opened
      expect(find.text('Settings'), findsOneWidget);
      container.dispose();
    });
    testWidgets('opens edit profile from speed dial',
        (WidgetTester tester) async {
      final userModel = UserModel(
        uid: 'testuid',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
      );

      final container = createProviderContainer(userModel: userModel);
      await tester.pumpWidget(createHomeScreen(container));
      await tester.pumpAndSettle();

      // Navigate to profile tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Open speed dial
      await tester.tap(find.byKey(const Key('speeddial-button')));
      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Verify settings screen is opened
      expect(find.byType(EditProfileSheet), findsOneWidget);
      container.dispose();
    });
  });
}
