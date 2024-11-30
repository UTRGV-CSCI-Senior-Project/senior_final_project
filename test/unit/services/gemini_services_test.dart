import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
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
  late Widget ref;

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
    group('getAllServices', () {
      test('should return list of services', () async {
        final mockQueryDocumentSnapshot1 =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockQueryDocumentSnapshot2 =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('services'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn(
            [mockQueryDocumentSnapshot1, mockQueryDocumentSnapshot2]);

        when(mockQueryDocumentSnapshot1.get('service')).thenReturn('Service 1');
        when(mockQueryDocumentSnapshot2.get('service')).thenReturn('Service 2');

        final result = await getAllServices();

        expect(result, equals(['Service 1', 'Service 2']));
      });

      test('should throw get-services-error on fail', () async {
        when(mockFirestore.collection('services'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenThrow(Exception('Fetch failed'));

        expect(
            getAllServices,
            throwsA(predicate((e) =>
                e is AppException &&
                e.toString().contains('get-services-error'))));
      });
    });
  });
}
