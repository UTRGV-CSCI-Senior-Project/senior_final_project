import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/onboarding_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../mocks/login_screen_test.mocks.dart';
import '../mocks/onboarding_screen_test.mocks.dart';
import '../mocks/user_repository_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockFirestoreServices mockFirestoreServices;
  late MockImagePicker mockImagePicker;
  late MockXFile mockXFile;
  final fullNameField = find.byKey(const Key('name-field'));
  final imagePickerButton = find.byKey(const Key('image-picker-button'));

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockFirestoreServices = MockFirestoreServices();
    mockImagePicker = MockImagePicker();
    mockXFile = MockXFile();
    when(mockFirestoreServices.getServices()).thenAnswer(
        (_) async => ['Nail Tech', 'Barber', 'Tattoo Artist', 'Car Detailer']);
  });

  ProviderContainer createProviderContainer() {
    return ProviderContainer(overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository),
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
      imagePickerProvider.overrideWithValue(mockImagePicker)
    ]);
  }

  Widget createOnboardingWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()));
  }

  group('Onboarding Screen', () {
    testWidgets('shows initial UI elements', (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      expect(find.text('Name and Profile Picture'), findsOneWidget);
      expect(find.text('This is how others will see you.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('shows error when trying to continue without name',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text("Please enter your full name."),
          findsOneWidget);
    });

    testWidgets('proceeds to second screen after adding image and name',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, 'Full Name');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(
          find.text("What professions are you interested in?"), findsOneWidget);
    });

    testWidgets('loads and displays services', (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, 'Full Name');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text("Nail Tech"), findsOneWidget);
      expect(find.text("Barber"), findsOneWidget);
      expect(find.text("Tattoo Artist"), findsOneWidget);
      expect(find.text("Car Detailer"), findsOneWidget);
    });

    testWidgets('allows selection of services', (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, 'Full Name');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('completes onboarding and navigates to HomeScreen',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, 'Full Name');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Done!"));

      verify(mockUserRepository.updateProfile(
              profilePicture: anyNamed('profilePicture'),
              fields: anyNamed('fields')))
          .called(1);
    });

    testWidgets('shows error message when update fails',
        (WidgetTester tester) async {
      final container = createProviderContainer();
      await tester.pumpWidget(createOnboardingWidget(container));
      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('path/to/image');
      when(mockUserRepository.updateProfile(
              profilePicture: anyNamed('profilePicture'),
              fields: anyNamed('fields')))
          .thenThrow(Exception('update failed'));

      await tester.tap(imagePickerButton);
      await tester.enterText(fullNameField, 'Full Name');

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nail Tech'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Done!"));
      await tester.pumpAndSettle();
      expect(find.text('Failed to update profile information. Please try again.'),
          findsOneWidget);
    });
  });
}
