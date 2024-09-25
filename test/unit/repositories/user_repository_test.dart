import 'package:mockito/mockito.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateMocks([AuthServices, UserFirestoreServices])
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late UserRepository userRepository;
  late MockAuthServices mockAuthServices;
  late MockUserFirestoreServices mockUserFirestoreServices;

  setUp(() {
    mockAuthServices = MockAuthServices();
    mockUserFirestoreServices = MockUserFirestoreServices();
    userRepository = UserRepository(mockAuthServices, mockUserFirestoreServices);
  });

  test('createUser successfully creates a user', () async {
    const username = "testUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = 'testUID';

    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    when(mockAuthServices.signUp(email: email, password: password))
        .thenAnswer((_) async => uid);
    when(mockUserFirestoreServices.addUser(any)).thenAnswer((_) async => {});

    await userRepository.createUser(username, email, password);

    verify(mockUserFirestoreServices.isUsernameUnique(username)).called(1);
    verify(mockAuthServices.signUp(email: email, password: password)).called(1);
    verify(mockUserFirestoreServices.addUser(any)).called(1);
  });

  test('createUser throws exception when username is not unique', () async {
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";

    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => false);

    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('Username is already taken'))));
  });

  test('createUser throws exception when sign up fails', () async {
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";

    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    when(mockAuthServices.signUp(email: email, password: password))
        .thenThrow(Exception('Sign up failed'));

    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('Exception: Sign up failed'))));

    verifyNever(mockUserFirestoreServices.addUser(any));
  });

  test('createUser throws exception when adding user to Firestore fails',
      () async {
    const username = "takenUser";
    const email = "test@example.com";
    const password = "Pass123!";
    const uid = "testUID";

    when(mockUserFirestoreServices.isUsernameUnique(username))
        .thenAnswer((_) async => true);
    when(mockAuthServices.signUp(email: email, password: password))
        .thenAnswer((_) async => uid);
    when(mockUserFirestoreServices.addUser(any))
        .thenThrow(Exception('Failed to add user to Firestore'));

    expect(
        () => userRepository.createUser(username, email, password),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('An error ocurred. Try again later'))));
  });
}
