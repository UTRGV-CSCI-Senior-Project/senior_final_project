import 'package:firebase_auth/firebase_auth.dart';
import 'package:folio/core/app_exception.dart';
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
    authServices = AuthServices(mockFirebaseAuth);
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
              email: 'test@email.com',
              password: 'Pass123!',
              username: 'username'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('other-error'))));
    });

    test('create account fails with weak-password FirebaseAuthException',
        () async {
      //When registering a user, return a weak-password exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'weak-password'));
      //Expect weak-pasword to be caught when registering a user
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('weak-password'))));
    });

    test('create account fails with email-already-in-use FirebaseAuthException',
        () async {
      //When registring a user, return a email-already-in-use exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'email-already-in-use'));
      //Expect email-already-in-use to be caught when registering a user
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException &&
              e.toString().contains('email-already-in-use'))));
    });

    test('create account fails with invalid-email FirebaseAuthException',
        () async {
      //When registering a user, return a invalid-email exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'invalid-email'));
      //Expect invalid-email to be caught when registering a user
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('invalid-email'))));
    });

    test('create account fails with too-many-requests FirebaseAuthException',
        () async {
      //When registering a user, return a too-many-requests exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'too-many-requests'));
      //Expect too-many-requests to be caught
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException &&
              e.toString().contains('too-many-requests'))));
    });

    test(
        'create account fails with network-request-failed FirebaseAuthException',
        () async {
      //When registering a user, return a network-request-failed exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer((_) =>
              throw FirebaseAuthException(code: 'network-request-failed'));
      //Expect a network-request-failed to be caught when registering a user
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException &&
              e.toString().contains('network-request-failed'))));
    });

    test('create account fails with generic exception', () async {
      //When registering a user, return a random error
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer((_) => throw Exception('Random Error'));
      //Expect the random error to be caught with unexpected-error
      expect(
          () => authServices.signUp(
              email: 'test@email.com', password: '1!', username: 'username'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('sign-up-error'))));
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
      expect(
          () => authServices.signIn(
              email: 'test@email.com', password: 'Pass123!'),
          returnsNormally);
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
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('other-error'))));
    });

    test('log in fails with invalid-email FirebaseAuthException', () async {
      //When logging, return a invalid-email exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'invalid-email'));
      //Expect invalid-email to be caught when logging in
      expect(
          () => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('invalid-email'))));
    });

    test('log in fails with user-not-found FirebaseAuthException', () async {
      //When logging, return a user-not-found exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'user-not-found'));
      //Expect user-not-found to be caught when logging in
      expect(
          () => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('user-not-found'))));
    });

    test('log in fails with wrong-password FirebaseAuthException', () async {
      //When logging, return a wrong-password exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@email.com', password: '1!'))
          .thenAnswer(
              (_) => throw FirebaseAuthException(code: 'wrong-password'));
      //Expect wrong-password to be caught when logging in
      expect(
          () => authServices.signIn(email: 'test@email.com', password: '1!'),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('wrong-password'))));
    });
  });

  group('signOut', () {
    test('signs out successfully', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

      await expectLater(authServices.signOut(), completes);

      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('throws sign-out-error on failure', () async {
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out failed'));

      expect(
          authServices.signOut(),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('sign-out-error'))));

      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });

  group('authStateChanges', () {
    test('emits a user when there is a user', () async {
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      expectLater(authServices.authStateChanges(), emitsInOrder([mockUser]));
    });

    test('emits null when there is no user logged in', () async {
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

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
      when(mockUser.delete())
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
          () async => await authServices.deleteUser(),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('user-not-found'))));
    });
  });

  group('sendVerificationEmail', () {
    test('sends verification email, when account is not verified', () async {
      //When the user is called to check their verification status, return false (for not verified)
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.emailVerified).thenReturn(false);
      when(mockUser.sendEmailVerification())
          .thenAnswer((_) async => Future.value());

      // Should complete normally
      await expectLater(
        authServices.sendVerificationEmail(),
        completes,
      );

      // Verify that sendEmailVerification was called
      verify(mockUser.sendEmailVerification()).called(1);
    });

    test("doesn't send verification email, when account is already verified",
        () async {
      //When the user is called to check their verification status, return true (for already verified)
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.emailVerified).thenReturn(true);

      // Should throw already verified
      expect(
        () => authServices.sendVerificationEmail(),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('already-verified'))),
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
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('email-verification-error'))),
      );
    });

    test('throws no-user, when user is null', () async {
      // Mock no current user
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Should throw email-verification-error
      expect(
        () => authServices.sendVerificationEmail(),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('no-user'))),
      );
    });
  });

  group('reauthenticateUser', () {
    test('reauthenticates user successfully', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.reauthenticateWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);
      await authServices.reauthenticateUser('password123');

      verify(mockUser.reauthenticateWithCredential(any)).called(1);
    });

    test('throws no-user error when current user is null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => authServices.reauthenticateUser('password123'),
        throwsA(predicate((e) => e is AppException && e.code == 'no-user')),
      );
    });

    test('throws no-email error when current user has no email', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn(null);

      expect(
        () => authServices.reauthenticateUser('password123'),
        throwsA(predicate((e) => e is AppException && e.code == 'no-email')),
      );
    });

    test('throws reauthenticate-user-error on other exceptions', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.reauthenticateWithCredential(any))
          .thenThrow(Exception('Unexpected error'));

      expect(
        () => authServices.reauthenticateUser('password123'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'reauthenticate-user-error')),
      );
    });
  });

  group('updateEmail', () {
    test('updates email successfully', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.verifyBeforeUpdateEmail('new@example.com'))
          .thenAnswer((_) async => {});

      await authServices.updateEmail('new@example.com');

      verify(mockUser.verifyBeforeUpdateEmail('new@example.com')).called(1);
    });
    test('throws no-user error when current user is null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => authServices.updateEmail('new@example.com'),
        throwsA(predicate((e) => e is AppException && e.code == 'no-user')),
      );
    });

    test('throws update-email-error on other exceptions', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.verifyBeforeUpdateEmail('new@example.com'))
          .thenThrow(Exception('Unexpected error'));

      expect(
        () => authServices.updateEmail('new@example.com'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'update-email-error')),
      );
    });
  });

  group('currentUserUid', () {
    test('returns uid when user is logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final result = await authServices.currentUserUid();
      expect(result, 'test-uid');

      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('returns null when no user is logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await authServices.currentUserUid();
      expect(result, null);

      verify(mockFirebaseAuth.currentUser).called(1);
    });
  });

  group('updatePassword', () {
    test('updates password successfully', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword('newPass123!'))
          .thenAnswer((_) async => Future.value());

      await authServices.updatePassword('newPass123!');

      verify(mockFirebaseAuth.currentUser).called(1);
      verify(mockUser.updatePassword('newPass123!')).called(1);
    });

    test('throws no-user error when current user is null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      expect(
        () => authServices.updatePassword('newPass123!'),
        throwsA(predicate((e) => e is AppException && e.code == 'no-user')),
      );
    });

    test('throws FirebaseAuthException codes properly', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword('newPass123!'))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => authServices.updatePassword('newPass123!'),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('weak-password'))),
      );
    });

    test('throws update-password-error on other exceptions', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.updatePassword('newPass123!'))
          .thenThrow(Exception('Unexpected error'));

      expect(
        () => authServices.updatePassword('newPass123!'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'update-password-error')),
      );
    });
  });
}
