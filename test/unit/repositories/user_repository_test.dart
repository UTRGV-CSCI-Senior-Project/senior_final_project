import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/services/storage_services.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import '../../mocks/firestore_services_test.mocks.dart';
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
    container = ProviderContainer(
      overrides: [
        authServicesProvider.overrideWithValue(mockAuthServices),
        firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
        storageServicesProvider.overrideWithValue(mockStorageServices)
      ]
    );
  });

  test('createUser successfully creates a user', () async {
    //Create valid necessary fields for creating a user
    const username = "testUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = 'testUID';

    //Return true for unique username
    when(mockFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Return a uid when sign up is called
    when(mockAuthServices.signUp(email: email, password: password, username: username))
        .thenAnswer((_) async => uid);
    //Return no exceptions (successfull) when the user is added to firestore
    when(mockFirestoreServices.addUser(any)).thenAnswer((_) async {});
    when(mockAuthServices.sendVerificationEmail()).thenAnswer((_) async {});

    //Create the user using the user repository
    final userRepository = container.read(userRepositoryProvider);
    await userRepository.createUser(username, email, password);

    //Verify that all necessary services for creating a user (username check, sign up, firestore) were called
    verify(mockFirestoreServices.isUsernameUnique(username)).called(1);
    verify(mockAuthServices.signUp(email: email, password: password, username: username)).called(1);
    verify(mockFirestoreServices.addUser(any)).called(1);
  });

  test('createUser throws exception when username is not unique', () async {
    //Create necessary information for creating a username
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";

    //Return false when username check is called. (false = username not uniqe)
    when(mockFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => false);
    final userRepository = container.read(userRepositoryProvider);
    //Expect username-taken to be caught
    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(equals('username-taken')));
  });

  test('createUser throws exception when sign up fails', () async {
    //Create necessary information for creating a username
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";

    //Return true when username check is called. (true == username unique)
    when(mockFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Throw an unexpected-error when signup is called
    when(mockAuthServices.signUp(email: email, password: password, username: username))
        .thenThrow('unexpected-error');
    final userRepository = container.read(userRepositoryProvider);

    //Expect unexpected-error to be caught
    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(equals('unexpected-error')));
    //Verify that addUser was not called (user not added to firestore)
    verifyNever(mockFirestoreServices.addUser(any));
  });

  test('createUser throws exception when adding user to Firestore fails',
      () async {
    //Create necessary information to create user
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = "testUID";

    //Return true when username check is called. (true == username uniquq)
    when(mockFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Return a uid when signup is called (successful signup)
    when(mockAuthServices.signUp(email: email, password: password, username: username))
        .thenAnswer((_) async => uid);
    //Throw an unexpected-error when trying to add user to firestore
    when(mockFirestoreServices.addUser(any))
        .thenThrow('unexpected-error');
    when(mockAuthServices.deleteUser()).thenAnswer((_)async {});
    final userRepository = container.read(userRepositoryProvider);

    //Expect unexpected-error to be caught
    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(equals('firestore-add-fail')));
  });
}
