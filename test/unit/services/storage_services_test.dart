import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/storage_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/auth_services_test.mocks.dart';
import '../../mocks/firestore_services_test.mocks.dart';
@GenerateMocks([FirebaseStorage, Reference, UploadTask, TaskSnapshot])
import '../../mocks/storage_services_test.mocks.dart';

void main() {
  late StorageServices storageServices;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockReference;
  late MockUploadTask mockUploadTask;
  late MockRef mockRef;
  late MockUser mockUser;
  late MockTaskSnapshot mockTaskSnapshot;

  setUp(() {
    mockFirebaseStorage = MockFirebaseStorage();
    mockRef = MockRef();
    mockUser = MockUser();
    mockReference = MockReference();
    mockTaskSnapshot = MockTaskSnapshot();
    mockUploadTask = MockUploadTask();
    storageServices = StorageServices(mockRef, mockFirebaseStorage);

    storageServices = StorageServices(mockRef, mockFirebaseStorage);

    provideDummy<AsyncValue<User?>>((const AsyncValue.data(null)));
  });

  group('StorageServices', () {
    test('uploadProfilePicture succeeds', () async {
      // Arrange
      final testFile = File('test_image.jpg');
      const testUid = 'test_user_id';
      const testDownloadUrl = 'https://test-download-url.com';

      // Mock behavior
      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);

      when(mockReference.child(any)).thenReturn(mockReference);

      when(mockReference.putFile(any)).thenAnswer((_) => mockUploadTask);

      when(mockReference.getDownloadURL())
          .thenAnswer((_) async => 'https://test-download-url.com');
      when(mockUploadTask.then(any, onError: anyNamed('onError')))
          .thenAnswer((invocation) {
        final completer = invocation.positionalArguments[0] as Function;
        return Future.value(completer(mockTaskSnapshot));
      });

      // Act
      final result = await storageServices.uploadProfilePicture(testFile);

      // Assert
      expect(result, equals(testDownloadUrl));
      verify(mockReference.putFile(testFile)).called(1);
      verify(mockReference.getDownloadURL()).called(1);
    });

    test('uploadProfilePicture throws error on no user', () async {
      // Arrange
      final testFile = File('test_image.jpg');

      // Mock behavior
      when(mockRef.read(authStateProvider)).thenReturn(const AsyncValue.data(null));

      // Assert
      expect(() => storageServices.uploadProfilePicture(testFile), throwsA('no-user'));
    });

    test('uploadProfilePicture throws generic error pfp-error', () async {
      // Arrange
      final testFile = File('test_image.jpg');
      const testUid = 'test_user_id';

      // Mock behavior
      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.putFile(any)).thenThrow(Exception('upload-error'));

      expect(() => storageServices.uploadProfilePicture(testFile), throwsA('pfp-error'));
    });


  });
}
