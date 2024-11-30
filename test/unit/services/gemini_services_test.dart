import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/user_repository_test.mocks.dart';
import 'gemini_services_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late GenerativeModel generativeModel;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>>
      mockQueryDocumentSnapshot;
  late MockFirestoreServices mockFirestoreServices;
  late GeminiServices geminiServices;

  setUp(() async {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot =
        MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockFirestoreServices = MockFirestoreServices();
    generativeModel = GenerativeModel(model: '', apiKey: '');
    geminiServices = GeminiServices();
  });

  tearDown(() {});

  group('Gemini Services api', () {
    test('fetchApiKey returns API key when document exists', () async {
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.get('gemini')).thenReturn('dummy-api-key');
      when(mockQueryDocumentSnapshot.exists).thenReturn(true);

      final apiKey = await fetchApiKey();

      expect(apiKey, 'dummy-api-key');
    });

    test('fetchApiKey returns null when document does not exist', () async {
      when(mockFirestore.collection('api')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('gemini'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => Future.value(mockDocumentSnapshot));

      when(mockDocumentSnapshot.exists).thenReturn(false);

      final apiKey = await fetchApiKey();

      expect(apiKey, isNull);
    });

    test('fetchApiKey returns null when there is an exception', () async {
      when(mockFirestore.collection('api')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('gemini'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenThrow(
          FirebaseException(plugin: 'Firestore', message: 'Some error'));

      final apiKey = await fetchApiKey();

      expect(apiKey, isNull);
    });
    // group('GeminiServices _generateContent', () {
    //   test('should return generated content when generation is successful',
    //       () async {
    //     final prompt = 'Generate content about Flutter';
    //     final apiKey = 'dummy-api-key';
    //     final contentResponse = 'Generated content about Flutter.';

    //     // Arrange: Mocking the generateContent method
    //     when(() => generativeModel.generateContent(any(), any()))
    //         .thenAnswer((_) async => ContentResponse(text: contentResponse));

    //     // Act: Calling _generateContent
    //     final result = await geminiServices._generateContent(prompt, apiKey);

    //     // Assert: Verify the content is correctly returned
    //     expect(result, contentResponse);
    //     verify(() => generativeModel.generateContent(any())).called(1);
    //   });

    //   test('should return null when there is an exception', () async {
    //     final prompt = 'Generate content about Flutter';
    //     final apiKey = 'dummy-api-key';

    //     // Arrange: Simulate an error during content generation
    //     when(() => generativeModel.generateContent(any()))
    //         .thenThrow(Exception('Generation error'));

    //     // Act: Calling _generateContent
    //     final result = await geminiServices._generateContent(prompt, apiKey);

    //     // Assert: Verify the result is null
    //     expect(result, null);
    //     verify(() => generativeModel.generateContent(any())).called(1);
    //   });
    // });
  });
}
