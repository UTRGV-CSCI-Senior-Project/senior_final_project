import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/profile_tab.dart';

void main() {
  group('EditProfile Tests', () {
    final mockUserModel = UserModel(
        uid: '1',
        fullName: 'Test User',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        profilePictureUrl: 'https://example.com/pic.jpg',
        preferredServices: ['Barber', 'Nail Tech']);

    final mockPortfolioModel = PortfolioModel(
      service: 'Photography',
      images: [
        {'downloadUrl': 'https://example.com/image1.jpg', 'filePath': 'path1'},
        {'downloadUrl': 'https://example.com/image2.jpg', 'filePath': 'path2'},
      ],
    );

    testWidgets('displays user information correctly',
        (WidgetTester tester) async {
      // Build the widget and wait for it to settle.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EditProfile(
              userModel: mockUserModel,
              portfolioModel: mockPortfolioModel,
            ),
          ),
        ),
      );

      // Wait for the widget tree to settle completely.
      await tester.pumpAndSettle();

      // Ensure that the TabBar with the key 'tab-bar-key' is found.
      expect(find.byType(TabBar), findsOneWidget);

      // Ensure other widgets are also found (verify user details, etc.)
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('email@email.com'), findsOneWidget);
      expect(find.text('Photography'), findsOneWidget);
    });
  });
}
