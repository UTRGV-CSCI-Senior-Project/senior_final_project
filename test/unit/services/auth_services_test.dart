import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
import '../../mocks/auth_services_test.mocks.dart';

void main() {
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

  group('sign up', ()  {
    test('create account successfully', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@email.com',
        password: 'Pass123!',
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final result = await authServices.signUp(
          email: 'test@email.com', password: 'Pass123!');
      expect(result, 'test-uid');
    });

    test('create account fails with general FirebaseAuthException', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: 'Pass123!'))
          .thenAnswer((_) => throw FirebaseAuthException(code: 'other-error'));

      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: 'Pass123!'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              'Exception: An error ocurred. Try again later')));
    });

    test('create account fails with weak-password FirebaseAuthException', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'weak-password'));

      expect(
          () => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              'Exception: The password provided is too weak.')));
    });

    test('create account fails with email-already-in-use FirebaseAuthException',
        () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'email-already-in-use'));

      expect(
          () => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              'Exception: An account already exists for that email.')));
    });

    test('create account fails with generic exception', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer((_) => throw Exception('Random Error'));

      expect(
          () => authServices.signUp(email: 'test@email.com', password: '1!'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              'Exception: An unexpected error ocurred. Try again later')));
    });
  });
}
