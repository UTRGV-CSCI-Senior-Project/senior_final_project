import 'package:mockito/mockito.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateMocks([AuthServices, UserFirestoreServices])
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  //Mock all necessary services
  late UserRepository userRepository;
  late MockAuthServices mockAuthServices;
  late MockUserFirestoreServices mockUserFirestoreServices;

  setUp(() {
    mockAuthServices = MockAuthServices();
    mockUserFirestoreServices = MockUserFirestoreServices();
    userRepository = UserRepository(mockAuthServices, mockUserFirestoreServices);
  });

  test('createUser successfully creates a user', () async {
    //Create valid necessary fields for creating a user
    const username = "testUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = 'testUID';

    //Return true for unique username
    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Return a uid when sign up is called
    when(mockAuthServices.signUp(email: email, password: password))
        .thenAnswer((_) async => uid);
    //Return no exceptions (successfull) when the user is added to firestore
    when(mockUserFirestoreServices.addUser(any)).thenAnswer((_) async => {});

    //Create the user using the user repository
    await userRepository.createUser(username, email, password);

    //Verify that all necessary services for creating a user (username check, sign up, firestore) were called
    verify(mockUserFirestoreServices.isUsernameUnique(username)).called(1);
    verify(mockAuthServices.signUp(email: email, password: password)).called(1);
    verify(mockUserFirestoreServices.addUser(any)).called(1);
  });

  test('createUser throws exception when username is not unique', () async {
    //Create necessary information for creating a username
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";

    //Return false when username check is called. (false = username not uniqe)
    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => false);

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
    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Throw an unexpected-error when signup is called
    when(mockAuthServices.signUp(email: email, password: password))
        .thenThrow('unexpected-error');

    //Expect unexpected-error to be caught
    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(equals('unexpected-error')));
    //Verify that addUser was not called (user not added to firestore)
    verifyNever(mockUserFirestoreServices.addUser(any));
  });

  test('createUser throws exception when adding user to Firestore fails',
      () async {
    //Create necessary information to create user
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = "testUID";

    //Return true when username check is called. (true == username uniquq)
    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    //Return a uid when signup is called (successful signup)
    when(mockAuthServices.signUp(email: email, password: password))
        .thenAnswer((_) async => uid);
    //Throw an unexpected-error when trying to add user to firestore
    when(mockUserFirestoreServices.addUser(any))
        .thenThrow('unexpected-error');

    //Expect unexpected-error to be caught
    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(equals('unexpected-error')));
  });
}
