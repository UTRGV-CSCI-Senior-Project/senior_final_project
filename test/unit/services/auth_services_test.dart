import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/services/auth_services.dart';
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
    test('creates account successfully', () async {
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
          email: 'test@email.com', password: 'Pass123!', username: 'username');
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
              email: 'test@email.com', password: 'Pass123!', username: 'username'),
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
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
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
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(equals('email-already-in-use')));
    });

    test('create account fails with invalid-email FirebaseAuthException',
        () async {
      //When registering a user, return a invalid-email exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'invalid-email'));
      //Expect invalid-email to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(equals('invalid-email')));
    });

    test('create account fails with too-many-requests FirebaseAuthException',
        () async {
      //When registering a user, return a too-many-requests exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'too-many-requests'));
      //Expect too-many-requests to be caught
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(equals('too-many-requests')));
    });

        test('create account fails with network-request-failed FirebaseAuthException',
        () async {
      //When registering a user, return a network-request-failed exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'network-request-failed'));
      //Expect a network-request-failed to be caught when registering a user
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(equals('network-request-failed')));
    });

    test('create account fails with generic exception', () async {
      //When registering a user, return a random error
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer((_) => throw Exception('Random Error'));
      //Expect the random error to be caught with unexpected-error
      expect(() => authServices.signUp(email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(equals('unexpected-error')));
    });
  });

  group('log in', () {

    test('logs in successfully', () async {
      //when logging in a user, return a mock user (successful log in)
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'Pass123!',
      )).thenAnswer((_) async => mockUserCredential);

      //When checking the user, return user created previously
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      //expect the signIn method to return normally (no error)
      expect(() => authServices.signIn(email: 'test@email.com', password: 'Pass123!'), returnsNormally);
    });

    test('login fails with general FirebaseAuthException', () async {
      //When logging in, return a other-error exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: 'Pass123!'))
          .thenAnswer((_) => throw FirebaseAuthException(code: 'other-error'));
      //Expect other-error to be caught when logging in
      expect(
          () => authServices.signIn(
              email: 'test@email.com', password: 'Pass123!'),
          throwsA(equals('other-error')));
    });

     test('log in fails with invalid-email FirebaseAuthException',
        () async {
          //When logging, return a invalid-email exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'invalid-email'));
      //Expect invalid-email to be caught when logging in
      expect(() => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(equals('invalid-email')));
    });

    test('log in fails with user-not-found FirebaseAuthException',
        () async {
          //When logging, return a user-not-found exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'user-not-found'));
      //Expect user-not-found to be caught when logging in
      expect(() => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(equals('user-not-found')));
    });

    test('log in fails with wrong-password FirebaseAuthException',
        () async {
          //When logging, return a wrong-password exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'wrong-password'));
      //Expect wrong-password to be caught when logging in
      expect(() => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(equals('wrong-password')));
    });

  });

  group('authStateChanges', () {
    test('emits a user when there is a user', () async {
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

      expectLater(authServices.authStateChanges(), emitsInOrder([mockUser]));
    });

    test('emits null when there is no user logged in', () async {
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null));

      expectLater(authServices.authStateChanges(), emitsInOrder([null]));
    });
  });

  group('deleteUser', () {
    test('deletes the current user', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.delete()).thenAnswer((_) async => Future.value());

      await authServices.deleteUser();

      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.delete()).called(1);

    });

    test('does nothing if there is no user logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.delete()).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(() async => await authServices.deleteUser(), throwsA(equals('user-not-found')));

    });
  });

  group('sendVerificationEmail', () {
    test('sends verification email, when account is not verified', () async {
      //When the user is called to check their verification status, return false (for not verified)
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.emailVerified).thenReturn(false);
      when(mockUser.sendEmailVerification()).thenAnswer((_) async => Future.value());

      // Should complete normally
      await expectLater(
        authServices.sendVerificationEmail(),
        completes,
      );

      // Verify that sendEmailVerification was called
      verify(mockUser.sendEmailVerification()).called(1);

    });

    test("doesn't send verification email, when account is already verified", () async {
      //When the user is called to check their verification status, return true (for already verified)
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.emailVerified).thenReturn(true);

      // Should throw already verified
      expect(() =>
        authServices.sendVerificationEmail(),
        throwsA(equals('already-verified')),
      );
    });

    test('throws email-verification-error when sending fails', () async {
      //When the user is called to check their verification status, return false (for not verified)
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.emailVerified).thenReturn(false);
      when(mockUser.sendEmailVerification())
          .thenThrow(Exception('Failed to send email'));

      // Should throw email-verification-error
      expect(
        () => authServices.sendVerificationEmail(),
        throwsA(equals('email-verification-error')),
      );
    });

    test('throws no-user, when user is null', () async {
 // Mock no current user
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Should throw email-verification-error
      expect(
        () => authServices.sendVerificationEmail(),
        throwsA(equals('no-user')),
      );
    });

  });
}
