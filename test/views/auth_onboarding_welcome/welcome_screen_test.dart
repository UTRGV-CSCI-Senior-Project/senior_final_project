import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/auth_onboarding_welcome/auth_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';

void main() {
  group('WelcomeScreen Tests', () {
    testWidgets('WelcomeScreen displays all required elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Check for text elements
      expect(find.text('FOLIO'), findsOneWidget);
      expect(find.text('Discover Local Talent,'), findsOneWidget);
      expect(find.text('Book with Ease'), findsOneWidget);

      // Check for buttons
      expect(find.byKey(const Key('signin-button')), findsOneWidget);
      expect(find.byKey(const Key('signup-button')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('Navigation to log in works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Test login button navigation
      await tester.tap(find.byKey(const Key('signin-button')));
      await tester.pumpAndSettle();

      // Verify navigation to AuthScreen with isLogin=true
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Sign In'), findsAny);
    });

    testWidgets('Navigation to sign up works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      // Test signup button navigation
      await tester.scrollUntilVisible(find.byKey(const Key('signup-button')), 50);
      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      // Verify navigation to AuthScreen with isLogin=false
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsAny);
    });
  });
}
