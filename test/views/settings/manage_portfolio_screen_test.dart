import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/views/settings/manage_portfolio_screen.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/create_portfolio_screen.mocks.dart';
import '../../mocks/login_screen_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockPortfolioRepository mockPortfolioRepository;
  late MockFirestoreServices mockFirestoreServices;
  late ProviderContainer container;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockPortfolioRepository = MockPortfolioRepository();
    mockFirestoreServices = MockFirestoreServices();

    container = ProviderContainer(overrides: [
      portfolioRepositoryProvider.overrideWithValue(mockPortfolioRepository),
      userRepositoryProvider.overrideWithValue(mockUserRepository),
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
    ]);
  });

  final testPortfolio = PortfolioModel(
    service: 'Barber',
    details: 'I am a barber',
    years: 5,
    months: 5,
    images: [
      {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
    ],
  );

  group('ManagePortfolioScreen Tests', () {
    
    testWidgets('displays portfolio information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Manage Portfolio'), findsOneWidget);
      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('5 years, 5 months'), findsOneWidget);
      expect(find.text('I am a barber'), findsOneWidget);
    });

    testWidgets('shows service selection dialog when service tile is tapped',
        (WidgetTester tester) async {
          when(mockFirestoreServices.getServices()).thenAnswer(
        (_) async => ['Nail Tech', 'Barber', 'Tattoo Artist', 'Car Detailer']);
       await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Barber'));
      await tester.pumpAndSettle();

      expect(find.text('Update the service you offer!'), findsOneWidget);
      expect(find.text('Choose what best fits your work.'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('shows experience update dialog when experience tile is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Experience'));
      await tester.pumpAndSettle();

      expect(find.text('Update your experience'), findsOneWidget);
      expect(find.text('Be as accurate as possible!'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('shows details update dialog when details tile is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('Update your work details!'), findsOneWidget);
      expect(find.text('What would potential clients like to know?'),
          findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('calls updatePortfolio when service is updated',
        (WidgetTester tester) async {
      when(mockPortfolioRepository.updatePortfolio(fields: anyNamed('fields')))
          .thenAnswer((_) async => {});
      when(mockFirestoreServices.getServices()).thenAnswer(
        (_) async => ['Nail Tech', 'Barber', 'Tattoo Artist', 'Car Detailer']);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Service'));
      await tester.pumpAndSettle();

      // Select a new service and update
      await tester.tap(find.text('Nail Tech'));
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      verify(mockPortfolioRepository
          .updatePortfolio(fields: {'service': 'Nail Tech'})).called(1);
    });

     testWidgets('calls updatePortfolio when experience is updated',
        (WidgetTester tester) async {
      when(mockPortfolioRepository.updatePortfolio(fields: anyNamed('fields')))
          .thenAnswer((_) async => {});
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Experience'));
      await tester.pumpAndSettle();

      // Select a new service and update
      await tester.enterText(find.byType(TextField).first, '6');
      await tester.enterText(find.byType(TextField).last, '2');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      verify(mockPortfolioRepository
          .updatePortfolio(fields: {'years': 6, 'months': 2})).called(1);
    });

     testWidgets('calls updatePortfolio when details are updated',
        (WidgetTester tester) async {
      when(mockPortfolioRepository.updatePortfolio(fields: anyNamed('fields')))
          .thenAnswer((_) async => {});
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Select a new service and update
      await tester.enterText(find.byType(TextField), 'I am a barber. I am a barber. I am a barber. I am a barber. I am a barber.');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      verify(mockPortfolioRepository
          .updatePortfolio(fields: {'details': 'I am a barber. I am a barber. I am a barber. I am a barber. I am a barber.'})).called(1);
    });

    testWidgets(
        'shows delete confirmation dialog when delete button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE PORTFOLIO'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete Portfolio'), findsOneWidget);
    });

    testWidgets(
        'calls deletePortfolio when delete is confirmed with correct password',
        (WidgetTester tester) async {
      when(mockUserRepository.reauthenticateUser(any))
          .thenAnswer((_) async => {});
      when(mockPortfolioRepository.deletePortfolio())
          .thenAnswer((_) async => {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ManagePortfolioScreen(portfolioModel: testPortfolio),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('DELETE PORTFOLIO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(find.text('Verify Password'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '123123');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      verify(mockUserRepository.reauthenticateUser('123123')).called(1);
      verify(mockPortfolioRepository.deletePortfolio()).called(1);
    });
  });
}
