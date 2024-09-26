import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/views/signup_screen.dart';

@GenerateMocks([UserRepository])
import '../mocks/signup_screen_test.mocks.dart';
void main() {
  final MockUserRepository mockUserRepository = MockUserRepository();
  final usernameField = find.byKey(const Key('username-field'));
  final emailField = find.byKey(const Key('email-field'));
  final passwordField = find.byKey(const Key('password-field'));
  final signUpButton = find.byKey(const Key('signup-button'));

  group('sign up page', () {
    testWidgets('shows all necessary fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));
      expect(usernameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(signUpButton, findsOneWidget);
    });

    testWidgets('Shows error on empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text('Please fill in all of the fields.'), findsOneWidget);

    });

    testWidgets('Calls createUser when username, email, password, are entered', (WidgetTester tester) async {
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      verify(mockUserRepository.createUser(username, email, password)).called(1);

    });

    testWidgets('Shows error when username is taken', (WidgetTester tester) async {
      const username = 'takenUsername';
      const email = 'email@email.com';
      const password = 'Pass123!';
      when(mockUserRepository.createUser(username, email, password)).thenThrow('username-taken');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('This username is already taken. Please try another one.'), findsOneWidget);
    });

    testWidgets('shows error when a generic firestore exception ocurrs',(WidgetTester tester) async {
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      when(mockUserRepository.createUser(username, email, password)).thenThrow('unexpected-error');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('An unknown error ocurred. Please try again later.'), findsOneWidget);
    });
    testWidgets('shows error when the password is weak',(WidgetTester tester) async {
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      when(mockUserRepository.createUser(username, email, password)).thenThrow('weak-password');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('The password provided is too weak.'), findsOneWidget);
    });
    testWidgets('shows error when the email is taken',(WidgetTester tester) async {
const username = 'username';
      const email = 'taken@email.com';
      const password = '1';
      when(mockUserRepository.createUser(username, email, password)).thenThrow('email-already-in-use');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('This email is already associated with another account.'), findsOneWidget);

    });
    testWidgets('shows error when a generic firebase auth exception ocurrs',(WidgetTester tester) async {
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      when(mockUserRepository.createUser(username, email, password)).thenThrow('unexpected-error');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('An unknown error ocurred. Please try again later.'), findsOneWidget);
    });




    
  });
}
