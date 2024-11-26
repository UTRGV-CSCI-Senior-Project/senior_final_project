
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/auth_onboarding_welcome/loading_screen.dart';

void main(){
  group('Loading Screen', () {
    testWidgets('LoadingScreen displays correct elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));
      
      // Verify FOLIO is present
      expect(find.text('FOLIO'), findsOneWidget);
      
      // Verify the image is present
      expect(find.byType(Image), findsOneWidget);
      
      // Verify animations are present
      expect(find.byType(RotationTransition), findsAny);
      expect(find.byType(ScaleTransition), findsAny);
    });
  });
}