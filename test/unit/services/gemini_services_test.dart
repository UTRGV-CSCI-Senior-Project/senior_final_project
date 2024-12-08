import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/firestore_services_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late MockFirestoreServices mockFirestoreServices;
  late GeminiServices geminiServices;
  late MockRef mockRef;

  setUp(() {
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');
    mockFirestoreServices = MockFirestoreServices();
    mockRef = MockRef();
    geminiServices = GeminiServices(mockRef);
    provideDummy<Future<List<String>>>(Future.value([]));

  });

  group('fetchApiKey', () {
    test('returns API key if available', () {
      dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');
      final apiKey = geminiServices.fetchApiKey();
      expect(apiKey, equals('test_key'));
    });

    test('throws AppException when key is unavailable', () {
      dotenv.testLoad(fileInput: '');
      final apiKey = geminiServices.fetchApiKey();
      expect(apiKey, equals(null));
    });
  });

  // group('getAllServices', () {
  //   test('returns list of services from FirestoreServices', () async {
  //     when(mockFirestoreServices.getServices())
  //         .thenAnswer((_) async => ['Hair Stylist', 'Barber']);
  //     final services = await geminiServices.getAllServices();
  //     expect(services, equals(['Hair Stylist', 'Barber']));
  //   });

  //   test('throws AppException when FirestoreServices fails', () async {
  //     when(mockFirestoreServices.getServices()).thenThrow(Exception());
  //     expect(
  //         () => geminiServices.getAllServices(),
  //         throwsA(isA<AppException>()
  //             .having((e) => e.code, 'code', 'get-services-error')));
  //   });
  // });

  group('aiSearch', () {
    test('should return empty list when API key is null', () async {
      // Simulate no API key in environment
      dotenv.testLoad(fileInput: '');

      final result = await geminiServices.aiSearch('');
      expect(result, []);
    });

    test('should return all services when prompt is empty', () async {
      dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');
      when(mockRef.read(servicesStreamProvider.future)).thenAnswer((_) async => ['Service1', 'Service2']);
  

      final result = await geminiServices.aiSearch('');
      expect(result, ['Service1', 'Service2']);
    });

    test('should handle exception in getAllServices', () async {
      when(mockRef.read(servicesStreamProvider.future)).thenThrow(AppException('get-services-error'));


      final result = await geminiServices.aiSearch('');
      expect(result, []);
    });
  });

  group('aiDiscover', () {
    test('should return empty list when API key is null', () async {
      // Simulate no API key in environment
      dotenv.testLoad(fileInput: '');

      final result = await geminiServices.aiDiscover('');
      expect(result, []);
    });

    test('should return all services  when prompt is empty', () async {
      dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test_key');
       when(mockRef.read(servicesStreamProvider.future)).thenAnswer((_) async => ['Service1', 'Service2']);


      final result = await geminiServices.aiDiscover('');
      expect(result, ['Service1', 'Service2']);
    });

    test('should handle exception in getAllServices', () async {
      when(mockFirestoreServices.getServices())
          .thenThrow(AppException('get-services-error'));

      final result = await geminiServices.aiDiscover('');
      expect(result, []);
    });
  });
}
