import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';

void main(){
  group('StateScreens Tests', () {
    testWidgets('LoadingView shows circular progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoadingView()));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ErrorView displays correct error message', (WidgetTester tester) async {
      const errorBigText = 'Error Occurred';
      const errorSmallText = 'Please try again later';
      
      await tester.pumpWidget(const MaterialApp(
        home: ErrorView(
          bigText: errorBigText,
          smallText: errorSmallText,
        ),
      ));
      
      expect(find.text(errorBigText), findsOneWidget);
      expect(find.text(errorSmallText), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

}