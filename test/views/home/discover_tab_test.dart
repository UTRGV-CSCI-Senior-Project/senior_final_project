import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/views/home/discover_tab.dart';

void main(){
  group('DiscoverTab Tests', () {

    testWidgets('search bar can receive input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child:  MaterialApp(
            home: Scaffold(
              body: DiscoverTab(),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test search');
      expect(find.text('test search'), findsOneWidget);
    });
  });
}