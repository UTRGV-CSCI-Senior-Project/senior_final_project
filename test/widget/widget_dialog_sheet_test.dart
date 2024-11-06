import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/widgets/account_item_widget.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:folio/widgets/logout_dialog.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:folio/widgets/settings_item_widget.dart';
import 'package:folio/widgets/update_email_dialog.dart';
import 'package:folio/widgets/verify_password_dialog.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockBuildContext mockBuildContext;

  setUp(() {
    mockBuildContext = MockBuildContext();
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
  });
  group('Edit Profile Sheet', () {
    testWidgets('shows correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EditProfileSheet(
                userModel: UserModel(
                  uid: '123123',
                  email: 'testemail@email.com',
                  isProfessional: false,
                  fullName: 'John Doe',
                  username: 'johndoe',
                  profilePictureUrl: 'https://example.com/profile.jpg',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('johndoe'), findsOneWidget);
      expect(find.byType(TextField), findsExactly(2));
      expect(find.byType(Image), findsOneWidget);
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
                mockBuildContext),
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
    testWidgets('shows correct logout message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LogoutDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Log out'), findsOneWidget);
      expect(
          find.text(
              "Are you sure you want to log out? You'll need to login again to use the app."),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);
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
                  updateEmailDialog(context, title, description, value, onFinish);
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
                  updateEmailDialog(context, title, description, value, onFinish);
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
                  verifyPasswordDialog(context, title, onVerified);
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
                  verifyPasswordDialog(context, title, onVerified);
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
}
