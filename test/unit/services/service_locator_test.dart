import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/auth_services_test.mocks.dart';
import '../../mocks/cloud_messaging_services_test.mocks.dart';
import '../../mocks/firestore_services_test.mocks.dart';
import '../../mocks/onboarding_screen_test.mocks.dart';
import '../../mocks/storage_services_test.mocks.dart';
import '../../mocks/home_screen_test.mocks.dart';
import '../../mocks/service_locator_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';


@GenerateMocks([GeminiServices])

void main() {
  late ProviderContainer container;
  MockFirebaseAuth mockFirebaseAuth;
  MockFirebaseFirestore mockFirebaseFirestore;
  MockFirebaseStorage mockFirebaseStorage;
  MockFirebaseFunctions mockFirebaseFunctions;
  MockFirebaseMessaging mockFirebaseMessaging;
  MockLocationService mockLocationService;
  late Stream<String> mockTokenRefreshStream;
  MockGeminiServices mockGeminiServices;
  MockAuthServices mockAuthServices;
  MockFirestoreServices mockFirestoreServices;
  MockStorageServices mockStorageServices;
  MockCloudMessagingServices mockCloudMessagingServices;


  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFunctions = MockFirebaseFunctions();
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    mockLocationService = MockLocationService();
    mockGeminiServices = MockGeminiServices();
    mockAuthServices = MockAuthServices();
    mockFirestoreServices = MockFirestoreServices();
    mockStorageServices = MockStorageServices();
    mockCloudMessagingServices = MockCloudMessagingServices();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        firebaseFirestoreProvider.overrideWithValue(mockFirebaseFirestore),
        firebaseStorageProvider.overrideWithValue(mockFirebaseStorage),
        firebaseFunctionsProvider.overrideWithValue(mockFirebaseFunctions),
        firebaseMessagingProvider.overrideWithValue(mockFirebaseMessaging),
        locationServiceProvider.overrideWithValue(mockLocationService),
        geminiServicesProvider.overrideWithValue(mockGeminiServices),
        authServicesProvider.overrideWithValue(mockAuthServices),
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        storageServicesProvider.overrideWithValue(mockStorageServices),
        cloudMessagingServicesProvider.overrideWithValue(mockCloudMessagingServices)
      ],
    );
     mockTokenRefreshStream = Stream.value('token');
    when(mockFirebaseMessaging.onTokenRefresh)
        .thenAnswer((_) => mockTokenRefreshStream);
  });

  tearDown(() {
    container.dispose();
  });
  group('Firebase Service Providers', () {
    test('Firebase service providers return correct instances', () {
      expect(container.read(firebaseAuthProvider), isA<MockFirebaseAuth>());
      expect(container.read(firebaseFirestoreProvider),
          isA<MockFirebaseFirestore>());
      expect(
          container.read(firebaseStorageProvider), isA<MockFirebaseStorage>());
      expect(container.read(firebaseFunctionsProvider),
          isA<MockFirebaseFunctions>());
      expect(container.read(firebaseMessagingProvider),
          isA<MockFirebaseMessaging>());
    });
  });

  group('Service Providers', () {
    test('Service providers are created successfully', () {
      expect(container.read(authServicesProvider), isNotNull);
      expect(container.read(firestoreServicesProvider), isNotNull);
      expect(container.read(storageServicesProvider), isNotNull);
      expect(container.read(cloudMessagingServicesProvider), isNotNull);
      expect(container.read(geminiServicesProvider), isNotNull);
    });
  });

  group('Repository Providers', () {
    test('Repository providers are created successfully', () {
      expect(container.read(userRepositoryProvider), isNotNull);
      expect(container.read(portfolioRepositoryProvider), isNotNull);
      expect(container.read(feedbackRepositoryProvider), isNotNull);
      expect(container.read(messageRepositoryProvider), isNotNull);
    });
  });

  group('Stream Providers', () {
    test('Stream providers are initializable', () {
      expect(container.read(authStateProvider), isNotNull);
      expect(container.read(userStreamProvider), isNotNull);
      expect(container.read(userDataStreamProvider), isNotNull);
      expect(container.read(chatroomStreamProvider), isNotNull);
    });
  });

  group('Location Providers', () {
    test('Location providers are created successfully', () {
      expect(container.read(locationServiceProvider), isNotNull);
      expect(container.read(currentPositionProvider), isNull);
      expect(container.read(positionStreamProvider), isNotNull);
      expect(container.read(nearbyPortfoliosProvider), isNotNull);
    });
  });

  group('Emulator Setup', () {
    test('setupEmulators can be called without error', () {
      expect(() => setupEmulators(useEmulators: true), returnsNormally);
      expect(() => setupEmulators(useEmulators: false), returnsNormally);
    });
  });

  group('ImagePicker Provider', () {
    setUp(() {
      container = ProviderContainer(
        overrides: [
          imagePickerProvider.overrideWithValue(MockImagePicker()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('ImagePicker provider returns an ImagePicker instance', () {
      expect(container.read(imagePickerProvider), isA<ImagePicker>());
    });
  });
}
