import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/settings/phone_verification_flow.dart';
import 'package:folio/widgets/sms_code_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/core/app_exception.dart';
import 'package:pinput/pinput.dart';
import '../../mocks/login_screen_test.mocks.dart';


void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('PhoneVerificationFlow Widget Tests', () {
    testWidgets('renders correctly with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: PhoneVerificationFlow(),
          ),
        ),
      );

      // Verify initial UI elements
      expect(find.text('Add your phone number'), findsOneWidget);
      expect(find.text('Send Code'), findsOneWidget);
      expect(find.byType(IntlPhoneField), findsOneWidget);
    });

    testWidgets('shows error on invalid phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: PhoneVerificationFlow(),
          ),
        ),
      );

      // Try to submit without entering phone number
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Please enter a valid phone number.'), findsOneWidget);
    });

    testWidgets('shows loading indicator during verification', (WidgetTester tester) async {
      when(mockUserRepository.verifyPhone(any))
          .thenAnswer((_) async => 'verification-id');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: PhoneVerificationFlow(),
          ),
        ),
      );

      // Enter valid phone number
      final phoneField = find.byType(IntlPhoneField);
      await tester.enterText(phoneField, '1234567890');
      await tester.pumpAndSettle();

      // Tap send code button
      await tester.tap(find.text('Send Code'));
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles successful verification flow', (WidgetTester tester) async {
      const verificationId = 'test-verification-id';
      const smsCode = '123456';

      when(mockUserRepository.verifyPhone(any))
          .thenAnswer((_) async => verificationId);
      when(mockUserRepository.verifySmsCode(verificationId, smsCode))
          .thenAnswer((_) async {});
      when(mockUserRepository.updateProfile(
        fields: anyNamed('fields'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: PhoneVerificationFlow(),
          ),
        ),
      );

      // Enter phone number and initiate verification
      final phoneField = find.byType(IntlPhoneField);
      await tester.enterText(phoneField, '1234567890');
      await tester.pump();

      await tester.tap(find.text('Send Code'));
      await tester.pump();

      // Verify SMS dialog appears
      expect(find.byType(SmsCodeDialog), findsOneWidget);

      // Enter SMS code
      final pinput = find.byType(Pinput);
      await tester.enterText(pinput, smsCode);
      await tester.pump();

      // Submit code
      await tester.tap(find.text('SUBMIT'));
      await tester.pump();

      // Verify success message
      expect(
        find.text('Your phone number was updated successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('handles verification error properly', (WidgetTester tester) async {
      when(mockUserRepository.verifyPhone(any))
          .thenThrow(AppException('verify-number-error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const MaterialApp(
            home: PhoneVerificationFlow(),
          ),
        ),
      );

      // Enter phone number and attempt verification
      final phoneField = find.byType(IntlPhoneField);
      await tester.enterText(phoneField, '1234567890');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('There was an error verifying you number. Try again later'), findsOneWidget);
    });
  });

  group('SmsCodeDialog Widget Tests', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => getSmsCodeFromUser(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog elements
      expect(find.text('Verification'), findsOneWidget);
      expect(find.text('Enter the code sent to your number.'), findsOneWidget);
      expect(find.text('SUBMIT'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
    });

    testWidgets('handles SMS code entry and submission', (WidgetTester tester) async {
      String? resultCode;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultCode = await getSmsCodeFromUser(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog and enter code
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final pinput = find.byType(Pinput);
      await tester.enterText(pinput, '123456');
      await tester.pumpAndSettle();

      // Submit code
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();

      expect(resultCode, '123456');
    });

    testWidgets('handles cancellation', (WidgetTester tester) async {
      String? resultCode;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  resultCode = await getSmsCodeFromUser(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(resultCode, isNull);
    });
  });
}