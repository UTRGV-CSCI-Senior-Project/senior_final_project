import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
import '../../mocks/auth_services_test.mocks.dart';

void main() {
  //Create necessary mocks for services
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthServices authServices;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authServices = AuthServices(firebaseAuth: mockFirebaseAuth);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });
  tearDown(() {});

  group('sign up', () {
    test('create account successfully', () async {
      //when registering a user, return a mock user (successful registration)
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@email.com',
        password: 'Pass123!',
      )).thenAnswer((_) async => mockUserCredential);

      //When checking the user, return user created previously
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      //expect the signUp method to return the correct uid
      final result = await authServices.signUp(
          email: 'test@email.com', password: 'Pass123!');
      expect(result, 'test-uid');
    });

    test('create account fails with general FirebaseAuthException', () async {
      //When registering a user, return a other-error exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: 'Pass123!'))
          .thenAnswer((_) => throw FirebaseAuthException(code: 'other-error'));
      //Expect other-error to be caught when registering a user
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: 'Pass123!'),
          throwsA(equals('other-error')));
    });

    test('create account fails with weak-password FirebaseAuthException',
        () async {
          //When registering a user, return a weak-password exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'weak-password'));
      //Expect weak-pasword to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('weak-password')));
    });

    test('create account fails with email-already-in-use FirebaseAuthException',
        () async {
      //When registring a user, return a email-already-in-use exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'email-already-in-use'));
      //Expect email-already-in-use to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('email-already-in-use')));
    });

    test('create account fails with invalid email FirebaseAuthException',
        () async {
      //When registering a user, return a invalid-email exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'invalid-email'));
      //Expect invalid-email to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('invalid-email')));
    });

    test('create account fails with invalid email FirebaseAuthException',
        () async {
      //When registering a user, return a too-many-requests exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'too-many-requests'));
      //Expect too-many-requests to be caught
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('too-many-requests')));
    });

        test('create account fails with invalid email FirebaseAuthException',
        () async {
      //When registering a user, return a network-request-failed exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'network-request-failed'));
      //Expect a network-request-failed to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('network-request-failed')));
    });

    test('create account fails with generic exception', () async {
      //When registering a user, return a random error
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer((_) => throw Exception('Random Error'));
      //Expect the random error to be caught with unexpected-error
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(equals('unexpected-error')));
    });
  });
}
