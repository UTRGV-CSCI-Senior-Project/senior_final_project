import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/firestore_services_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

@GenerateMocks([GenerativeModel])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirestoreServices mockFirestoreServices;
  late WidgetRef mockRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
  });

  test('fetchApiKey returns API key when document exists', () async {
    // Arrange: Set up the mock behavior for Firestore
    when(mockFirestore.collection('api')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('gemini'))
        .thenReturn(mockDocumentReference);
    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockDocumentSnapshot);

    // Mock `exists` and `['key']`
    when(mockDocumentSnapshot.exists).thenReturn(true);
    when(mockDocumentSnapshot.data()).thenReturn({'key': 'dummy-api-key'});

    // Act: Call the function
    final apiKey = await fetchApiKey();

    // Assert: Check if the return value matches the expected key
    expect(apiKey, 'dummy-api-key');
  });

  test('fetchApiKey returns null when document does not exist', () async {
    // Arrange: Set up the mock behavior for Firestore
    when(mockFirestore.collection('api')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('gemini'))
        .thenReturn(mockDocumentReference);
    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockDocumentSnapshot);

    // Mock `exists` to return false
    when(mockDocumentSnapshot.exists).thenReturn(false);

    // Act: Call the function
    final apiKey = await fetchApiKey();

    // Assert: Check if the return value is null
    expect(apiKey, isNull);
  });

  test('fetchApiKey returns null when there is an exception', () async {
    // Arrange: Set up the mock behavior for Firestore to throw an exception
    when(mockFirestore.collection('api')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('gemini'))
        .thenReturn(mockDocumentReference);
    when(mockDocumentReference.get()).thenThrow(
        FirebaseException(plugin: 'Firestore', message: 'Some error'));

    // Act: Call the function
    final apiKey = await fetchApiKey();

    // Assert: Check if the return value is null
    expect(apiKey, isNull);
  });
}
