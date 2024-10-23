import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/services/storage_services.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateMocks([AuthServices, FirestoreServices, StorageServices])
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  //Mock all necessary services
  late ProviderContainer container;
  late MockAuthServices mockAuthServices;
  late MockFirestoreServices mockFirestoreServices;
  late MockStorageServices mockStorageServices;

  setUp(() {
    mockAuthServices = MockAuthServices();
    mockFirestoreServices = MockFirestoreServices();
    mockStorageServices = MockStorageServices();
    container = ProviderContainer(overrides: [
      authServicesProvider.overrideWithValue(mockAuthServices),
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
      storageServicesProvider.overrideWithValue(mockStorageServices)
    ]);
  });

  group('createUser', () {
    test('successfully creates a user', () async {
      //Create valid necessary fields for creating a user
      const username = "testUser";
      const email = "test@example.com";
      const password = "Pass123!";
      const uid = 'testUID';

      //Return true for unique username
      when(mockFirestoreServices.isUsernameUnique(username))
          .thenAnswer((_) async => true);
      //Return a uid when sign up is called
      when(mockAuthServices.signUp(
              email: email, password: password, username: username))
          .thenAnswer((_) async => uid);
      //Return no exceptions (successfull) when the user is added to firestore
      when(mockFirestoreServices.addUser(any)).thenAnswer((_) async {});
      when(mockAuthServices.sendVerificationEmail()).thenAnswer((_) async {});

      //Create the user using the user repository
      final userRepository = container.read(userRepositoryProvider);
      await userRepository.createUser(username, email, password);

      //Verify that all necessary services for creating a user (username check, sign up, firestore) were called
      verify(mockFirestoreServices.isUsernameUnique(username)).called(1);
      verify(mockAuthServices.signUp(
              email: email, password: password, username: username))
          .called(1);
      verify(mockFirestoreServices.addUser(any)).called(1);
      verify(mockAuthServices.sendVerificationEmail()).called(1);
    });

    test('throws exception when username is not unique', () async {
      //Create necessary information for creating a username
      const username = "takenUser";
      const email = "test@example.com";
      const password = "Pass123!";

      //Return false when username check is called. (false = username not uniqe)
      when(mockFirestoreServices.isUsernameUnique(username))
          .thenAnswer((_) async => false);
      final userRepository = container.read(userRepositoryProvider);
      //Expect username-taken to be caught
      expect(() => userRepository.createUser(username, email, password), throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('username-taken')
  )));
    });

    test('throws exception when sign up fails', () async {
      //Create necessary information for creating a username
      const username = "takenUser";
      const email = "test@example.com";
      const password = "Pass123!";

      //Return true when username check is called. (true == username unique)
      when(mockFirestoreServices.isUsernameUnique(username))
          .thenAnswer((_) async => true);
      //Throw an unexpected-error when signup is called
      when(mockAuthServices.signUp(
              email: email, password: password, username: username))
          .thenThrow(AppException('sign-up-error'));
      final userRepository = container.read(userRepositoryProvider);

      //Expect unexpected-error to be caught
      expect(() => userRepository.createUser(username, email, password),
          throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('sign-up-error')
  )));
      //Verify that addUser was not called (user not added to firestore)
      verifyNever(mockFirestoreServices.addUser(any));
    });

    test('throws exception when adding user to Firestore fails', () async {
      //Create necessary information to create user
      const username = "takenUser";
      const email = "test@example.com";
      const password = "Pass123!";
      const uid = "testUID";

      //Return true when username check is called. (true == username uniquq)
      when(mockFirestoreServices.isUsernameUnique(username))
          .thenAnswer((_) async => true);
      //Return a uid when signup is called (successful signup)
      when(mockAuthServices.signUp(
              email: email, password: password, username: username))
          .thenAnswer((_) async => uid);
      //Throw an unexpected-error when trying to add user to firestore
      when(mockFirestoreServices.addUser(any)).thenThrow(AppException('add-user-error'));
      when(mockAuthServices.deleteUser()).thenAnswer((_) async {});
      final userRepository = container.read(userRepositoryProvider);

      //Expect unexpected-error to be caught
      expect(() => userRepository.createUser(username, email, password),
         throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('add-user-error')
  )));

        // verify(mockAuthServices.deleteUser()).called(1);

    });
  });

  group('signIn', () {
    test('signs in successfully', () async {
      const email = 'testEmail@email.com';
      const password = 'testPassword';

      when(mockAuthServices.signIn(email: email, password: password)).thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.signIn(email, password), completes);

      verify(mockAuthServices.signIn(email: email, password: password)).called(1);
    });


    test('throws wrong-password when sign in credentials are incorrect', () async {
      const email = 'testEmail@email.com';
      const password = 'WrongPassword';

      when(mockAuthServices.signIn(email: email, password: password)).thenThrow(AppException('wrong-password'));

      final userRepository = container.read(userRepositoryProvider);
      expect(() => userRepository.signIn(email, password), throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('wrong-password')
  )));
    });
  });

  group('signOut', () {
    test('signs out successfully', () async {
      when(mockAuthServices.signOut()).thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.signOut(), completes);

      verify(mockAuthServices.signOut()).called(1);
    });

    test('throws error when sign out fails', () async {
      when(mockAuthServices.signOut()).thenThrow(AppException('sign-out-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(() => userRepository.signOut(), throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('sign-out-error')
  )));
    });
  });

  group('updateProfile', () {
    test('updates profile with new profile picture and fields', () async {
      final mockFile = File('test_path');
      final downloadUrl = 'https://example.com/profile.jpg';
      final fieldsToUpdate = {
        'username': 'newUsername'
      };

      when(mockStorageServices.uploadProfilePicture(mockFile)).thenAnswer((_) async => downloadUrl);
      when(mockFirestoreServices.updateUser({'profilePictureUrl': downloadUrl, 'username': 'newUsername'})).thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.updateProfile(profilePicture: mockFile, fields: fieldsToUpdate), completes);

      verify(mockStorageServices.uploadProfilePicture(mockFile)).called(1);
      verify(mockFirestoreServices.updateUser({'profilePictureUrl': downloadUrl, 'username': 'newUsername'})).called(1);
    });

    test('throws error when update fails', () async {
      final fieldsToUpdate = {
        'username': 'newUsername'
      };

      when(mockFirestoreServices.updateUser(fieldsToUpdate)).thenThrow(AppException('update-profile-failed'));
      final userRepository = container.read(userRepositoryProvider);

      expect(() => userRepository.updateProfile(fields: fieldsToUpdate), throwsA(predicate((e) => 
    e is AppException && 
    e.toString().contains('update-profile-failed')
  )));
    });
  });
}
