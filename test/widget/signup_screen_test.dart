import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/views/signup_screen.dart';

@GenerateMocks([UserRepository])
import '../mocks/signup_screen_test.mocks.dart';
void main() {
  //Create necessary mocks and keys for necessary fields
  final MockUserRepository mockUserRepository = MockUserRepository();
  final usernameField = find.byKey(const Key('username-field'));
  final emailField = find.byKey(const Key('email-field'));
  final passwordField = find.byKey(const Key('password-field'));
  final signUpButton = find.byKey(const Key('signup-button'));

  group('sign up page', () {
    testWidgets('shows all necessary fields', (WidgetTester tester) async {
      //Load the sign up screen
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      //Expect all the fields to be found
      expect(usernameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(signUpButton, findsOneWidget);
    });

    testWidgets('Shows error on empty fields', (WidgetTester tester) async {
      //Load the sign up screen
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      //Tap sign up button without entering necessary data
      await tester.tap(signUpButton);
      await tester.pump();

      //Expect to find error for empty fields
      expect(find.text('Please fill in all of the fields.'), findsOneWidget);

    });

    testWidgets('Calls createUser when username, email, password, are entered', (WidgetTester tester) async {
      //Create necessary data for user and load sign up screen
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      //Enter all data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pump();

      //Verify that the createUser (from userrepository) was called
      verify(mockUserRepository.createUser(username, email, password)).called(1);

    });

    testWidgets('Shows error when username is taken', (WidgetTester tester) async {
      //Create neccessary data, and load sign up screen
      const username = 'takenUsername';
      const email = 'email@email.com';
      const password = 'Pass123!';
      //when createUser is called, throw the username-taken 
      when(mockUserRepository.createUser(username, email, password)).thenThrow('username-taken');
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      //Enter necessary data to corresponding fields (using a taken username)
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pump();

      //Expect to see error with taken username message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('This username is already taken. Please try another one.'), findsOneWidget);
    });

    testWidgets('shows error when a generic firestore exception ocurrs',(WidgetTester tester) async {
      //Create necessary information for a user
      const username = 'username';
      const email = 'email@email.com';
      const password = 'Pass123!';
      //When createUser is called, throw an unexpected error
      when(mockUserRepository.createUser(username, email, password)).thenThrow('unexpected-error');
      //Wait for sign up screen to laod
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));

      //Enter data to corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pump();

      //Expect to see error message for generic exception
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('An unknown error ocurred. Please try again later.'), findsOneWidget);
    });
    testWidgets('shows error when the password is weak',(WidgetTester tester) async {
      //Create necessary information for a user
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      //When createuser is called, throw weak-password
      when(mockUserRepository.createUser(username, email, password)).thenThrow('weak-password');
      //Load sign up screen
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));
      //Enter data to necessary fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap signup button
      await tester.tap(signUpButton);
      await tester.pump();
      //Expect to see error for weak password
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('The password provided is too weak.'), findsOneWidget);
    });
    testWidgets('shows error when the email is taken',(WidgetTester tester) async {
      //Create necessary information for user
const username = 'username';
      const email = 'taken@email.com';
      const password = '1';
      //When createuser is called, throw email-already-in-use
      when(mockUserRepository.createUser(username, email, password)).thenThrow('email-already-in-use');
      //Load sign up screen
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));
      //Enter data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pump();

      //Expect to see error message for email-already-in-use
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('This email is already associated with another account.'), findsOneWidget);

    });
    testWidgets('shows error when a generic firebase auth exception ocurrs',(WidgetTester tester) async {
      //Create necessary data for user
      const username = 'username';
      const email = 'email@email.com';
      const password = '1';
      //When createuser is called throw an unexpected error
      when(mockUserRepository.createUser(username, email, password)).thenThrow('unexpected-error');
      //load sign up screen
      await tester.pumpWidget(MaterialApp(
        home: SignupScreen(
          userRepository: mockUserRepository,
        ),
      ));
      //Enter data into corresponding fields
      await tester.enterText(usernameField, username);
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
  
      //Tap sign up button
      await tester.tap(signUpButton);
      await tester.pump();
      //Expect to see error message for general exception.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('An unknown error ocurred. Please try again later.'), findsOneWidget);
    });




    
  });
}
