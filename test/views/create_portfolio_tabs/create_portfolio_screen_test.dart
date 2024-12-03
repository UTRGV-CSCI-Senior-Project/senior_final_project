import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/repositories/portfolio_repository.dart';
import 'package:folio/views/create_portfolio_tabs/create_portfolio_screen.dart';
import 'package:folio/views/create_portfolio_tabs/input_experience_screen.dart';
import 'package:folio/views/create_portfolio_tabs/more_details_screen.dart';
import 'package:google_maps_places_autocomplete_widgets/widgets/address_autocomplete_textfield.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/create_portfolio_screen_test.mocks.dart';
import '../../mocks/onboarding_screen_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

@GenerateMocks([PortfolioRepository])
void main() {
  late MockPortfolioRepository mockPortfolioRepository;
  late MockFirestoreServices mockFirestoreServices;
  late MockImagePicker mockImagePicker;
  late MockXFile mockXFile;
  final nextButton = find.byKey(const Key('portfolio-next-button'));
  final closeButton = find.byKey(const Key('close-button'));

  setUp(() {
    mockPortfolioRepository = MockPortfolioRepository();
    mockFirestoreServices = MockFirestoreServices();
    mockImagePicker = MockImagePicker();
    mockXFile = MockXFile();
    dotenv.testLoad(
        fileInput: 'GEMINI_API_KEY=test_key\nPLACES_API_KEY=test_key');
    when(mockFirestoreServices.getServices()).thenAnswer(
        (_) async => ['Nail Tech', 'Barber', 'Tattoo Artist', 'Car Detailer']);
  });

  ProviderContainer createProviderContainer() {
    return ProviderContainer(
      overrides: [
        imagePickerProvider.overrideWithValue(mockImagePicker),
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        portfolioRepositoryProvider.overrideWithValue(mockPortfolioRepository),
      ],
    );
  }

  Widget createPortfolioScreen(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
          home: CreatePortfolioScreen(
        name: 'Professionals Name',
        uid: 'test-uid',
      )),
    );
  }

  group('Create Portfolio Screen', () {
    testWidgets('shows initial screen with progress indicator and next button',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(nextButton, findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(closeButton, findsOneWidget);
    });

    testWidgets('shows error when trying to proceed without selecting service',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Please select a service.'), findsOneWidget);
    });

    testWidgets('proceeds to experience screen after selecting service',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));
      await tester.pumpAndSettle();
      // Select a service (you'll need to adjust this based on your ChooseService widget implementation)
      await tester
          .tap(find.byKey(const Key('Barber-button'))); // Assuming this exists
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify we're on the experience screen
      expect(find.byType(InputExperience), findsOneWidget);
    });

    testWidgets('can pick images and proceed to more details screen',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));
      await tester.pumpAndSettle();
      // Select service
      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Input experience (adjust based on your InputExperience widget implementation)
      // Assuming you have number input fields for years and months
      await tester.enterText(find.byKey(const Key('Years-field')), '2');
      await tester.enterText(find.byKey(const Key('Months-field')), '6');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Mock file selection
      when(mockImagePicker.pickMultiImage()).thenAnswer(
          (_) async => [mockXFile, mockXFile, mockXFile, mockXFile, mockXFile]);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(find.byKey(const Key('image-picker-button')));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // More details screen
      expect(find.byType(MoreDetailsScreen), findsOneWidget);
    });

    testWidgets('shows error when less than 5 images are chosen',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));
      await tester.pumpAndSettle();
      // Select service
      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Input experience (adjust based on your InputExperience widget implementation)
      // Assuming you have number input fields for years and months
      await tester.enterText(find.byKey(const Key('Years-field')), '2');
      await tester.enterText(find.byKey(const Key('Months-field')), '6');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Mock file selection
      when(mockImagePicker.pickMultiImage())
          .thenAnswer((_) async => [mockXFile, mockXFile]);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(find.byKey(const Key('image-picker-button')));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Show error for image count
      expect(find.text('Please upload at least 5 images.'), findsOneWidget);
    });

    testWidgets('can proceed through entire flow', (WidgetTester tester) async {
      when(mockPortfolioRepository.createPortfolio(
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
        any,
      )).thenAnswer((_) async {});
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));
      await tester.pumpAndSettle();
      // Select service
      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('Years-field')), '2');
      await tester.enterText(find.byKey(const Key('Months-field')), '6');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Mock file selection
      when(mockImagePicker.pickMultiImage()).thenAnswer(
          (_) async => [mockXFile, mockXFile, mockXFile, mockXFile, mockXFile]);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(find.byKey(const Key('image-picker-button')));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('details-field')), 'Test portfolio details');
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(
          find.text(
              "Enter your business location.\nOthers won't be able to see this."),
          findsOneWidget);
      final AddressAutocompleteTextField autocompleteField =
          tester.widget(find.byType(AddressAutocompleteTextField));

      final mockPlace =
          Place(city: 'New York', state: 'NY', lat: 40.7128, lng: -74.0060);

      autocompleteField.onSuggestionClick?.call(mockPlace);
      await tester.pump();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      verify(mockPortfolioRepository.createPortfolio(
        'Nail Tech',
        'Test portfolio details',
        6,
        2,
        any,
        {'city': 'New York', 'state': 'NY'},
        {'latitude': 40.7128, 'longitude': -74.0060},
        'Professionals Name',
        'test-uid',
      )).called(1);

      // Verify navigation back
      expect(find.byType(CreatePortfolioScreen), findsNothing);
    });

    testWidgets('can remove image from upload images screen',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createPortfolioScreen(container));
      await tester.pumpAndSettle();
      // Select service
      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Input experience (adjust based on your InputExperience widget implementation)
      // Assuming you have number input fields for years and months
      await tester.enterText(find.byKey(const Key('Years-field')), '2');
      await tester.enterText(find.byKey(const Key('Months-field')), '6');
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Mock file selection
      when(mockImagePicker.pickMultiImage()).thenAnswer(
          (_) async => [mockXFile, mockXFile, mockXFile, mockXFile, mockXFile]);
      when(mockXFile.path).thenReturn('path/to/image');
      await tester.tap(find.byKey(const Key('image-picker-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove-image-2')));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Show error for image count
      expect(find.text('Please upload at least 5 images.'), findsOneWidget);
    });
  });
}
