import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/core/service_locator.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/views/auth_screen.dart';

@GenerateMocks([UserRepository])
import '../mocks/signup_screen_test.mocks.dart';

void main() {
  //Create necessary mocks and keys for necessary fields
  late MockUserRepository mockUserRepository;
  final emailField = find.byKey(const Key('email-field'));
  final passwordField = find.byKey(const Key('password-field'));
  final logInButton = find.byKey(const Key('login-button'));

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  ProviderContainer createProviderContainer() {
    return ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(mockUserRepository)],
    );
  }

  Widget createLogInWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AuthScreen(isLogin: true),
        ));
  }

  group('log in page', () {
    testWidgets('shows all necessary fields', (WidgetTester tester) async {
      //Load the log in screen
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Expect all the fields to be found
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(logInButton, findsOneWidget);
    });

    testWidgets('Shows error on empty fields', (WidgetTester tester) async {
      //Load the log in screen
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Tap log in button without entering necessary data
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();

      //Expect to find error for empty fields
      expect(find.text('Please fill in all of the fields.'), findsOneWidget);
    });

    testWidgets('Calls signIn when email and password are entered',
        (WidgetTester tester) async {
      //Create necessary data for user and load log in screen
      const email = 'email@email.com';
      const password = 'Pass123!';
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter all data into corresponding fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap log in button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();

      //Verify that the signIn (from user repository) was called
      verify(mockUserRepository.signIn(email, password))
          .called(1);
    });

    testWidgets('Shows error when credentials are incorrect',
        (WidgetTester tester) async {
      //Create neccessary data, and load log in screen
      const email = 'email@email.com';
      const password = 'Pass123!';
      //when signIn is called, throw the username-taken
      when(mockUserRepository.signIn(email, password))
          .thenThrow('invalid-credential');
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter necessary data to corresponding fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap log in button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();

      //Expect to see error with taken username message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'Your email address or password is incorrect.'),
          findsOneWidget);
    });

    testWidgets('shows error when a generic firestore exception ocurrs',
        (WidgetTester tester) async {
      //Create necessary information for a user
      const email = 'email@email.com';
      const password = 'Pass123!';
      //When signIn is called, throw an unexpected error
      when(mockUserRepository.signIn(email, password))
          .thenThrow('unexpected-error');
      //Wait for log in screen to laod
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter data to corresponding fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap log in button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();

      //Expect to see error message for generic exception
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'An unknown error ocurred. Please try again later.'),
          findsOneWidget);
    });
    testWidgets('shows error when the account has been disabled',
        (WidgetTester tester) async {
      //Create necessary information for a user
      const email = 'email@email.com';
      const password = '1';
      //When signIn is called, throw user-disabled
      when(mockUserRepository.signIn( email, password))
          .thenThrow('user-disabled');
      //Load log in screen
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter data to necessary fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap login button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();
      //Expect to see error for user disabled
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('The account for the provided email has been disabled.'),
          findsOneWidget);
    });
    testWidgets('shows error when there is no account for the credentials',
        (WidgetTester tester) async {
      //Create necessary information for user
      const email = 'taken@email.com';
      const password = '1';
      //When signIn is called, throw user-not-found
      when(mockUserRepository.signIn(email, password))
          .thenThrow('user-not-found');
      //Load log in screen
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter data into corresponding fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap log in button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();

      //Expect to see error message for user-not-found
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'There is no user corresponding to the email provided.'),
          findsOneWidget);
    });
    testWidgets('shows error when a generic firebase auth exception ocurrs',
        (WidgetTester tester) async {
      //Create necessary data for user
      const email = 'email@email.com';
      const password = '1';
      //When signIn is called throw an unexpected error
      when(mockUserRepository.signIn(email, password))
          .thenThrow('unexpected-error');
      //load log in screen
      final container = createProviderContainer();
      await tester.pumpWidget(createLogInWidget(container));

      //Enter data into corresponding fields
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);

      //Tap log in button
      await tester.ensureVisible(logInButton);
      await tester.tap(logInButton);
      await tester.pumpAndSettle();
      //Expect to see error message for general exception.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'An unknown error ocurred. Please try again later.'),
          findsOneWidget);
    });
  });
}
