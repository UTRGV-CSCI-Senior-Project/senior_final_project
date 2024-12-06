import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/home_tab.dart';
import 'package:folio/views/home/update_services_screen.dart';
import 'package:folio/widgets/portfolio_card.dart';

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
        ProviderScope(
          child: MaterialApp(
          home: Scaffold(
            body: HomeTab(userModel: user),
          ),
        ),)
        
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
        ProviderScope(
          
          child: MaterialApp(
          home: Scaffold(
            body: HomeTab(userModel: user),
          ),
        ),)
        
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify navigation to UpdateServicesScreen
      expect(find.byType(UpdateServicesScreen), findsOneWidget);
    });

    testWidgets('shows no portfolios if there is no nearby ones', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          nearbyPortfoliosProvider.overrideWith((ref){
            return [];
          })
        ]
        );
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: MaterialApp(home: Scaffold(body: HomeTab(userModel: user),),))
      );
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioCard), findsNothing);

      expect(find.text('No portfolios found nearby.'), findsOneWidget);
    });

     testWidgets('shows  portfolios if there is  nearby ones', (WidgetTester tester) async {
  
          
          
      final container = ProviderContainer(
        overrides: [
          nearbyPortfoliosProvider.overrideWith((ref){
            return [
              PortfolioModel(service: 'Photographer', uid: 'test-uid', details:'Professional photography', years: 6, months: 7,  images: [],location: {'city': 'City', 'state': 'state'}, latAndLong: {'latitude': 40.7128, 'longitude': -74.0060}, professionalsName: 'Test Name',),
              PortfolioModel(service: 'Barber', uid: 'test-uid2', details:'Professional barber', years: 5, months: 7,  images: [],location: {'city': 'Hidalgo', 'state': 'Texas'}, latAndLong: {'latitude': 40.7128, 'longitude': -74.0060}, professionalsName: 'Test Name2',)

            ];
          })
        ]
        );
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: MaterialApp(home: Scaffold(body: HomeTab(userModel: user),),))
      );
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioCard), findsExactly(2));
      expect(find.text('Photographer'), findsOneWidget);
      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('Test Name'), findsOneWidget);
      expect(find.text('Test Name2'), findsOneWidget);
    });
  });
}