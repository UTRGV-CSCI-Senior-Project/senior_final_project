import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/home_tab.dart';
import 'package:folio/views/home/update_services_screen.dart';

void main(){
   group('HomeTab Tests', () {
    final user = UserModel(
          uid: '1',
          fullName: 'Test User',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false,
          preferredServices: ['Barber', 'Nail Tech']);

    testWidgets('displays user preferences correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTab(userModel: user),
          ),
        ),
      );

      // Verify preferences section
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Verify service chips
      expect(find.text('BARBER'), findsOneWidget);
      expect(find.text('NAIL TECH'), findsOneWidget);
    });

    testWidgets('edit services button navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTab(userModel: user),
          ),
        ),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify navigation to UpdateServicesScreen
      expect(find.byType(UpdateServicesScreen), findsOneWidget);
    });
  });
}