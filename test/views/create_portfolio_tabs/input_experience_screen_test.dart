import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/create_portfolio_tabs/input_experience_screen.dart';

void main(){
  group('Input Experience Screen Tests', () {
    testWidgets('allows years and months input', (WidgetTester tester) async {
      int? years;
      int? months;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:  InputExperience(
            onExperienceEntered: (y, m) {
              years = y;
              months = m;
            },
          ),
          )
         
        ),
      );

      await tester.enterText(find.byKey(const Key('Years-field')), '5');
      await tester.enterText(find.byKey(const Key('Months-field')), '6');

      expect(years, equals(5));
      expect(months, equals(6));
    });

    testWidgets('only accepts numeric input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputExperience(onExperienceEntered: (_, __) {}),
          )
        ),
      );

      await tester.enterText(find.byKey(const Key('Years-field')), 'abc');
      expect(find.text('abc'), findsNothing);
    });
  });
}