import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/storage_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/auth_services_test.mocks.dart';
import '../../mocks/firestore_services_test.mocks.dart';
@GenerateMocks([FirebaseStorage, Reference, UploadTask, TaskSnapshot, ListResult])
import '../../mocks/storage_services_test.mocks.dart';

void main() {
  late StorageServices storageServices;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockReference;
  late MockUploadTask mockUploadTask;
  late MockRef mockRef;
  late MockUser mockUser;
  late MockTaskSnapshot mockTaskSnapshot;
  late MockListResult mockListResult;

  setUp(() {
    mockFirebaseStorage = MockFirebaseStorage();
    mockRef = MockRef();
    mockUser = MockUser();
    mockReference = MockReference();
    mockTaskSnapshot = MockTaskSnapshot();
    mockUploadTask = MockUploadTask();
    mockListResult = MockListResult();
    storageServices = StorageServices(mockRef, mockFirebaseStorage);

    storageServices = StorageServices(mockRef, mockFirebaseStorage);

    provideDummy<AsyncValue<User?>>((const AsyncValue.data(null)));
  });

  group('uploadProfilePicture', () {
    test('uploadProfilePicture succeeds', () async {
      final testFile = File('test_image.jpg');
      const testUid = 'test_user_id';
      const testDownloadUrl = 'https://test-download-url.com';

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

      expect(result, equals(testDownloadUrl));
      verify(mockReference.putFile(testFile)).called(1);
      verify(mockReference.getDownloadURL()).called(1);
    });

    test('uploadProfilePicture throws error on no user', () async {
      final testFile = File('test_image.jpg');

      when(mockRef.read(authStateProvider)).thenReturn(const AsyncValue.data(null));

      expect(() => storageServices.uploadProfilePicture(testFile), throwsA(predicate((error) => 
        error is AppException && 
        error.toString().contains('no-user')
      )));
    });

    test('uploadProfilePicture throws generic error pfp-error', () async {
      final testFile = File('test_image.jpg');
      const testUid = 'test_user_id';

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.putFile(any)).thenThrow(Exception('upload-error'));

      expect(() => storageServices.uploadProfilePicture(testFile), throwsA(predicate((error) => 
        error is AppException && 
        error.toString().contains('pfp-upload-error')
      )));
    });
  });

  group('uploadFilesForUser', () {
    test('uploadFilesForUser succeeds with multiple files', () async {
      final testFiles = [
        File('test_image1.jpg'),
        File('test_image2.jpg'),
      ];
      const testUid = 'test_user_id';
      const testDownloadUrl = 'https://test-download-url.com';

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.putFile(any)).thenAnswer((_) => mockUploadTask);
      when(mockReference.getDownloadURL())
          .thenAnswer((_) async => testDownloadUrl);
      when(mockUploadTask.then(any, onError: anyNamed('onError')))
          .thenAnswer((invocation) {
        final completer = invocation.positionalArguments[0] as Function;
        return Future.value(completer(mockTaskSnapshot));
      });

      final result = await storageServices.uploadFilesForUser(testFiles);

      expect(result.length, equals(2));
      expect(result[0]['downloadUrl'], equals(testDownloadUrl));
      verify(mockReference.putFile(any)).called(2);
      verify(mockReference.getDownloadURL()).called(2);
    });

    test('uploadFilesForUser throws error on no user', () async {
      final testFiles = [File('test_image.jpg')];

      when(mockRef.read(authStateProvider)).thenReturn(const AsyncValue.data(null));

      expect(() => storageServices.uploadFilesForUser(testFiles),
          throwsA(predicate((error) =>
              error is AppException && error.toString().contains('no-user'))));
    });

    test('uploadFilesForUser throws generic upload-files-error', () async {
      final testFiles = [File('test_image.jpg')];
      const testUid = 'test_user_id';

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.putFile(any)).thenThrow(Exception('upload-error'));

      expect(
          () => storageServices.uploadFilesForUser(testFiles),
          throwsA(predicate((error) =>
              error is AppException &&
              error.toString().contains('upload-files-error'))));
    });
  });

  group('deleteImage', (){
    test('deleteImage succeeds', () async {
      const testImagePath = 'test/image/path.jpg';

      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.delete()).thenAnswer((_) async => {});

      expect(storageServices.deleteImage(testImagePath), completes);
      verify(mockReference.delete()).called(1);
    });

    test('deleteImage throws delete-image-error on generic error', () async {
      const testImagePath = 'test/image/path.jpg';

      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.delete()).thenThrow(Exception('delete-error'));

      expect(
          () => storageServices.deleteImage(testImagePath),
          throwsA(predicate((error) =>
              error is AppException &&
              error.toString().contains('delete-image-error'))));
    });
  });

  group('deletePortfolio', () {
    test('deletePortfolio succeeds', () async {
      const testUid = 'test_user_id';
      final mockItems = [mockReference, mockReference];

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.listAll()).thenAnswer((_) async => mockListResult);
      when(mockListResult.items).thenReturn(mockItems);
      when(mockReference.delete()).thenAnswer((_) async => {});
      await storageServices.deletePortfolio();
      expect(storageServices.deletePortfolio(), completes);
      verify(mockReference.delete()).called(2);
    });

    test('deletePortfolio throws error on no user', () async {
      when(mockRef.read(authStateProvider)).thenReturn(const AsyncValue.data(null));

      // Assert
      expect(() => storageServices.deletePortfolio(),
          throwsA(predicate((error) =>
              error is AppException && error.toString().contains('no-user'))));
    });

    test('deletePortfolio throws delete-portfolio-error on generic error',
        () async {
      const testUid = 'test_user_id';

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(testUid);
      when(mockFirebaseStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.listAll()).thenThrow(Exception('delete-error'));

      // Assert
      expect(
          () => storageServices.deletePortfolio(),
          throwsA(predicate((error) =>
              error is AppException &&
              error.toString().contains('delete-portfolio-error'))));
    });
  });
}
