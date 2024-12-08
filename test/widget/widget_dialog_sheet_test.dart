import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/chatroom_screen.dart';
import 'package:folio/widgets/account_item_widget.dart';
import 'package:folio/widgets/chatroom_tile_widget.dart';
import 'package:folio/widgets/delete_account_dialog.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:folio/widgets/email_verification_dialog.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:folio/widgets/logout_dialog.dart';
import 'package:folio/widgets/message_tile_widget.dart';
import 'package:folio/widgets/portfolio_card.dart';
import 'package:folio/widgets/portfolio_list_item.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:folio/widgets/settings_item_widget.dart';
import 'package:folio/widgets/sort_filter_sheet.dart';
import 'package:folio/widgets/update_email_dialog.dart';
import 'package:folio/widgets/verify_password_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

import '../../integration_test/app_test.dart';
import '../mocks/inbox_tab_test.mocks.dart';
import '../mocks/signup_screen_test.mocks.dart';
import '../mocks/user_repository_test.mocks.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockBuildContext mockBuildContext;
  late MockUserRepository mockUserRepository;
  late MockImagePicker mockImagePicker;
  late MockFirestoreServices mockFirestoreServices;
  late ProviderContainer container;
  late MockMessageRepository mockMessageRepository;

  setUp(() {
    mockBuildContext = MockBuildContext();
    mockUserRepository = MockUserRepository();
    mockImagePicker = MockImagePicker();
    mockFirestoreServices = MockFirestoreServices();
    mockMessageRepository = MockMessageRepository();
    container = ProviderContainer(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  });

  group('Account Item Widget', () {
    testWidgets('Shows correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: accountItem(
              title: 'Test Title',
              context: mockBuildContext,
              value: '123',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('correctly calls onTap', (WidgetTester tester) async {
      bool testBool = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: accountItem(
              title: 'Test Title',
              context: mockBuildContext,
              value: '123',
              onTap: () {
                testBool = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Title'));
      await tester.pumpAndSettle();
      expect(testBool, true);
    });
  });
  group('Edit Profile Sheet', () {
    Widget createEditProfileWidget() {
      final testUser = UserModel(
        uid: '123123',
        email: 'testemail@email.com',
        isProfessional: false,
        fullName: 'John Doe',
        username: 'johndoe',
        profilePictureUrl: 'https://example.com/profile.jpg',
      );
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: EditProfileSheet(userModel: testUser),
          ),
        ),
      );
    }

    testWidgets('shows correct information', (WidgetTester tester) async {
      await tester.pumpWidget(createEditProfileWidget());

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('johndoe'), findsOneWidget);
      expect(find.byType(TextField), findsExactly(2));
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('shows error when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createEditProfileWidget());

      // Clear the text fields
      await tester.enterText(find.byKey(const Key('name-field')), '');
      await tester.enterText(find.byKey(const Key('username-field')), '');

      // Tap save button
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('update-button')));
      await tester.pump();

      // Verify error message
      expect(find.text('Please fill in all necessary fields.'), findsOneWidget);
    });
    testWidgets('handles username already taken error',
        (WidgetTester tester) async {
      when(mockFirestoreServices.isUsernameUnique(any))
          .thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(createEditProfileWidget());

      // Change username
      await tester.enterText(
          find.byKey(const Key('username-field')), 'newusername');

      // Tap save button
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('update-button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.byType(ErrorBox), findsOneWidget);
    });

    testWidgets('successfully updates profile', (WidgetTester tester) async {
      when(mockFirestoreServices.isUsernameUnique(any))
          .thenAnswer((_) => Future.value(true));

      when(mockUserRepository.updateProfile(fields: {
        'fullName': 'New Name',
        'username': 'newusername',
      })).thenAnswer((_) async {});

      await tester.pumpWidget(createEditProfileWidget());

      // Change name and username
      await tester.enterText(find.byKey(const Key('name-field')), 'New Name');
      await tester.enterText(
          find.byKey(const Key('username-field')), 'newusername');

      // Tap save button
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('update-button')));
      await tester.pumpAndSettle();

      //Verify update was called with correct parameters
      verify(mockUserRepository.updateProfile(
        fields: {
          'fullName': 'New Name',
          'username': 'newusername',
        },
      )).called(1);

      // Verify navigation
      expect(find.byType(EditProfileSheet), findsNothing);
    });
  });

  group('Error Widget', () {
    testWidgets('shows correct error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBox(
              errorMessage: 'Test error message',
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('Input Field Widget', () {
    testWidgets('shows correct label, hint text, and functions',
        (WidgetTester tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: inputField(
                'name-field',
                'Full Name',
                'Enter name',
                TextInputType.text,
                TextEditingController(),
                (value) {},
                mockBuildContext,
                focusNode),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Test');
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Log Out Dialog', () {
    Widget createLogOutDialog() {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: LogoutDialog(),
          ),
        ),
      );
    }

    testWidgets('shows correct logout message', (WidgetTester tester) async {
      await tester.pumpWidget(createLogOutDialog());

      expect(find.text('Log out'), findsOneWidget);
      expect(
          find.text(
              "Are you sure you want to log out? You'll need to login again to use the app."),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);
    });

    testWidgets('Cancel button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createLogOutDialog());

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Logout button triggers sign out and dismisses dialog',
        (WidgetTester tester) async {
      // Setup mock behavior
      when(mockUserRepository.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(createLogOutDialog());

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap logout button
      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();

      // Verify signOut was called
      verify(mockUserRepository.signOut()).called(1);

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Service Selection Widget', () {
    testWidgets('displays services correctly', (WidgetTester tester) async {
      final services = ['Service A', 'Service B', 'Service C'];
      final initialSelectedServices = {
        'Service A': true,
        'Service B': false,
        'Service C': true
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ServiceSelectionWidget(
              services: services,
              initialSelectedServices: initialSelectedServices,
              onServicesSelected: (_) {},
              isLoading: false,
            ),
          ),
        ),
      );

      // Verify that all services are displayed
      for (final service in services) {
        expect(find.text(service), findsOneWidget);
      }

      // Verify that the initial selections are correct
      expect(find.byIcon(Icons.check), findsExactly(2));
    });

    testWidgets('handles single selection mode', (WidgetTester tester) async {
      String selectedService = "";
      final services = ['Service A', 'Service B', 'Service C'];
      final initialSelectedServices = {
        'Service A': true,
        'Service B': false,
        'Service C': true
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ServiceSelectionWidget(
              services: services,
              initialSelectedServices: initialSelectedServices,
              onServicesSelected: (service) {
                selectedService = service;
              },
              isLoading: false,
              singleSelectionMode: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Service B'));
      await tester.tap(find.text('Service A'));
      await tester.pumpAndSettle();

      // Verify that only 'Service A' is selected
      expect(selectedService, 'Service A');
    });
  });

  group('Settings Item Widget', () {
    testWidgets('displays correctly', (WidgetTester tester) async {
      const title = 'Settings Item';
      const icon = Icon(Icons.settings);
      onTap() {}
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SettingsItem(
                title: title,
                leading: icon,
                onTap: onTap,
              ),
            ),
          ),
        ),
      );

      // Verify that the title and icon are displayed
      expect(find.text(title), findsOneWidget);
      expect(find.byWidget(icon), findsOneWidget);

      // Verify that the trailing arrow is displayed
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

      // Verify that the divider is displayed
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('calls onTap correctly', (WidgetTester tester) async {
      bool tapped = false;
      const title = 'Settings Item';
      const icon = Icon(Icons.settings);
      onTap() {
        tapped = true;
      }

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SettingsItem(
                title: title,
                leading: icon,
                onTap: onTap,
              ),
            ),
          ),
        ),
      );

      // Tap on the SettingsItem
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Verify that the onTap callback was called
      expect(tapped, isTrue);
    });
  });

  group('Update Email Dialog', () {
    testWidgets('displays correctly', (WidgetTester tester) async {
      const title = 'Update Email';
      const description = 'Enter your new email address.';
      const value = 'current@email.com';
      onFinish(String newEmail) {}

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    updateAccountDialog(
                        context, title, description, value, onFinish);
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.byType(Dialog), findsOneWidget);

      // Verify that the title, description, and input field are displayed
      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onFinish correctly', (WidgetTester tester) async {
      const title = 'Update Email';
      const description = 'Enter your new email address.';
      const value = 'current@email.com';
      String newEmail = '';
      onFinish(String email) {
        newEmail = email;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    updateAccountDialog(
                        context, title, description, value, onFinish);
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Enter a new email and tap the 'Update' button
      await tester.enterText(find.byType(TextField), 'new@email.com');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Verify that the onFinish callback was called with the new email
      expect(newEmail, 'new@email.com');
    });
  });

  group('Verify Password Dialog', () {
    testWidgets('displays correctly', (WidgetTester tester) async {
      const title = 'Verify Password';
      onVerified(String password) {}

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    verifyPasswordDialog(
                        context,
                        title,
                        'Please verify your account before continuing.',
                        onVerified);
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.byType(Dialog), findsOneWidget);

      // Verify that the title and input field are displayed
      expect(find.text(title), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onVerified correctly', (WidgetTester tester) async {
      const title = 'Verify Password';
      String password = '';
      onVerified(String pass) {
        password = pass;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    verifyPasswordDialog(
                        context,
                        title,
                        'Please verify your account before continuing.',
                        onVerified);
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Enter a password and tap the 'Verify' button
      await tester.enterText(find.byType(TextField), 'mypassword');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      // Verify that the onVerified callback was called with the entered password
      expect(password, 'mypassword');
    });
  });

  group('DeleteAccountDialog', () {
    testWidgets('displays correctly with custom title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DeleteDialog(
                title: 'Profile',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify that the dialog title is displayed with custom title
      expect(find.text('Delete Profile'), findsOneWidget);

      // Verify that the warning message is displayed with custom title
      expect(
        find.text(
            'Are you sure you want delete your profile? All your profile data will be lost.'),
        findsOneWidget,
      );

      // Verify that both buttons are present
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);

      // Verify styling elements
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TextButton), findsExactly(2));
    });

    testWidgets('Cancel button closes the dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DeleteDialog(
                title: 'Account',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Tap the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed
      expect(find.byType(DeleteDialog), findsNothing);
    });

    testWidgets('DELETE button triggers onPressed callback',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DeleteDialog(
                title: 'Account',
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the DELETE button
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      // Verify that the callback was triggered
      expect(wasPressed, true);
    });
  });

  group('EmailVerificationDialog', () {
    testWidgets('displays the correct title and default message',
        (WidgetTester tester) async {
      // Show the EmailVerificationDialog in the widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationDialog(),
            ),
          ),
        ),
      );

      // Verify the title and default message
      expect(find.text('Verify Email'), findsOneWidget);
      expect(
        find.text(
            "Your email address has not been verified yet. Would you like to us to send a verification link to your email?"),
        findsOneWidget,
      );
    });

    testWidgets('displays a custom message if provided',
        (WidgetTester tester) async {
      const customMessage =
          "Your email address needs to be verified before adding a phone number.";

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationDialog(message: customMessage),
            ),
          ),
        ),
      );

      // Verify the custom message is displayed
      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('closes dialog when "No" button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationDialog(),
            ),
          ),
        ),
      );

      // Tap the "No" button and pump the widget
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Ensure the dialog is removed from the widget tree
      expect(find.byType(AlertDialog), findsNothing);
      // Ensure `sendEmailVerification` was not called
      verifyNever(mockUserRepository.sendEmailVerification());
    });

    testWidgets(
        'calls sendEmailVerification and closes dialog when "Send" button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationDialog(),
            ),
          ),
        ),
      );

      // Tap the "Send" button and pump the widget
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      // Verify the `sendEmailVerification` method is called
      verify(mockUserRepository.sendEmailVerification()).called(1);
      // Ensure the dialog is removed from the widget tree
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('ChatRoomTile', () {
    testWidgets(
      'displays correct participant info, last message, and timestamp',
      (WidgetTester tester) async {
        final mockChatroom = ChatroomModel(
            id: 'user1_user2',
            participants: [
              ChatParticipant(uid: 'user1', identifier: 'User One'),
              ChatParticipant(uid: 'user2', identifier: 'User Two')
            ],
            lastMessage: MessageModel(
                senderId: 'user1',
                recieverId: 'user2',
                message: 'Hello, do you have any appointments?',
                timestamp: DateTime.now()),
            participantIds: ['user1', 'user2']);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ChatRoomTile(
                    chatroom: mockChatroom,
                    currentUserId: 'user1',
                    sender: UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'username',
        isProfessional: false)),
              ),
            ),
          ),
        );

        expect(find.text('User Two'), findsOneWidget);
        expect(
            find.text('Hello, do you have any appointments?'), findsOneWidget);

        final avatar = find.byType(CircleAvatar);
        expect(avatar, findsOneWidget);
      },
    );

    testWidgets(
      'navigates to ChatroomScreen on tap',
      (WidgetTester tester) async {
        final mockChatroom = ChatroomModel(
            id: 'user1_user2',
            participants: [
              ChatParticipant(uid: 'user1', identifier: 'User One'),
              ChatParticipant(uid: 'user2', identifier: 'User Two')
            ],
            lastMessage: MessageModel(
                senderId: 'user1',
                recieverId: 'user2',
                message: 'Hello, do you have any appointments?',
                timestamp: DateTime.now()),
            participantIds: ['user1', 'user2']);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              messageRepositoryProvider.overrideWithValue(mockMessageRepository)
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ChatRoomTile(
                    chatroom: mockChatroom,
                    currentUserId: 'user1',
                    sender: UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'username',
        isProfessional: false)),
              ),
            ),
          ),
        );

        when(mockMessageRepository.getChatroomMessages('user1_user2'))
            .thenAnswer((_) => Stream.value([
                  MessageModel(
                      senderId: 'user1',
                      recieverId: 'user2',
                      message: 'Hello, do you have any appointments?',
                      timestamp: DateTime.now())
                ]));

        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        expect(find.byType(ChatroomScreen), findsOneWidget);
        expect(find.text('User Two'), findsOneWidget);
        expect(
            find.text('Hello, do you have any appointments?'), findsOneWidget);
      },
    );
  });

  group('MessageTile', () {
    testWidgets(
        'displays message and timestamp with correct alignment if current user sent it',
        (WidgetTester tester) async {
      final mockMessage = MessageModel(
        message: 'Hello, how are you?',
        senderId: 'user1',
        timestamp: DateTime(2024, 11, 26, 14, 30),
        recieverId: 'user2',
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageTile(
            message: mockMessage,
            otherUserId: 'user2',
          ),
        ),
      ));

      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.text('11/26/24 2:30'), findsOneWidget);

      // Check alignment
      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets(
      'displays message and timestamp with correct alignment if other user sent it',
      (WidgetTester tester) async {
        final mockMessage = MessageModel(
          message: 'Im good',
          senderId: 'user2',
          timestamp: DateTime(2024, 11, 26, 14, 45),
          recieverId: 'user1',
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: MessageTile(
              message: mockMessage,
              otherUserId: 'user2',
            ),
          ),
        ));

        expect(find.text('Im good'), findsOneWidget);
        expect(find.text('11/26/24 2:45'), findsOneWidget);

        // Check alignment
        final align = tester.widget<Align>(find.byType(Align));
        expect(align.alignment, Alignment.centerLeft);

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;

        // Check color
        expect(decoration.color, Colors.grey[600]);
      },
    );
  });

  group('PortfolioCard', () {
    final mockLocationService = MockLocationService();
    final testPortfolio = PortfolioModel(
      uid: '123',
      professionalsName: 'John Doe',
      service: 'Photography',
      latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
      address: '1234s Street',
      images: [],
    );
    final testUser = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'username',
        isProfessional: false);

    testWidgets('PortfolioCard renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPositionProvider.overrideWith((ref) {
              return Position(
                  latitude: 40.64,
                  longitude: -74.0059,
                  timestamp: DateTime.now(),
                  accuracy: 10.0,
                  altitude: 0.0,
                  heading: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0);
            }),
            locationServiceProvider.overrideWithValue(mockLocationService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PortfolioCard(
                portfolio: testPortfolio,
                currentUser: testUser,
              ),
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);

      expect(find.text('Photography'), findsOneWidget);

      expect(find.text('5 mi away'), findsOneWidget);

      expect(find.byKey(const Key('view-portfolio-button')), findsOneWidget);
    });
  });

  group('PortfolioListItem', () {
    final mockLocationService = MockLocationService();
    final testPortfolio = PortfolioModel(
      uid: '123',
      professionalsName: 'John Doe',
      service: 'Photography',
      latAndLong: {'latitude': 40.7128, 'longitude': -74.0060},
      address: '1234s Street',
      images: [],
    );
    final testUser = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        username: 'username',
        isProfessional: false);

    testWidgets('PortfolioCard renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPositionProvider.overrideWith((ref) {
              return Position(
                  latitude: 40.64,
                  longitude: -74.0059,
                  timestamp: DateTime.now(),
                  accuracy: 10.0,
                  altitude: 0.0,
                  heading: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0);
            }),
            locationServiceProvider.overrideWithValue(mockLocationService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PortfolioListItem(
                portfolio: testPortfolio,
                currentUser: testUser,
              ),
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);

      expect(find.text('Photography'), findsOneWidget);

      expect(find.text('5 mi away'), findsOneWidget);
    });
  });

  group('SortAndFilterSheet', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSortFilterSheet(
                      context,
                      'Distance',
                      'Ascending',
                      10.0,
                      ['Service1'],
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('shows SortFilterSheet and interacts with options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      when(mockFirestoreServices.getServices())
          .thenAnswer((_) async => ['Service1', 'Service2', 'Service3']);

      expect(find.text('Sort and Filter'), findsOneWidget);

      await tester.tap(find.text('Distance'));
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsOneWidget);
      await tester.tap(find.text('Name').last);
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsOneWidget);
      await tester.scrollUntilVisible(find.byKey(const Key('add-radius')), 50);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-radius')));
      await tester.pump();
      expect(find.text('15 mi'), findsOneWidget);

      await tester.tap(find.byKey(const Key('remove-radius')));
      await tester.pump();
      expect(find.text('10 mi'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Service1');
      await tester.pumpAndSettle();
      expect(find.text('Service1'), findsOneWidget);
      expect(find.text('Service2'), findsNothing);
    });
  });
}
