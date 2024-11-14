import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/create_portfolio_tabs/more_details_screen.dart';

void main() {
  group('More Details Screen Tests', () {
    testWidgets('allows text input', (WidgetTester tester) async {
      String? enteredDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoreDetailsScreen(
              onDetailsEntered: (details) => enteredDetails = details,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('details-field')),
        'Test portfolio details',
      );

      expect(enteredDetails, equals('Test portfolio details'));
    });
  });
}
