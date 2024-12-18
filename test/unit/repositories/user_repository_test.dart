import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/cloud_messaging_services.dart';
import 'package:folio/services/storage_services.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import '../../mocks/auth_services_test.mocks.dart';
import '../../mocks/create_portfolio_screen_test.mocks.dart';
@GenerateMocks(
    [AuthServices, FirestoreServices, StorageServices, CloudMessagingServices])
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  //Mock all necessary services
  late ProviderContainer container;
  late MockAuthServices mockAuthServices;
  late MockFirestoreServices mockFirestoreServices;
  late MockStorageServices mockStorageServices;
  late MockUser mockUser;
  late MockPortfolioRepository mockPortfolioRepository;
  late MockCloudMessagingServices mockCloudMessagingServices;

  setUp(() {
    mockAuthServices = MockAuthServices();
    mockFirestoreServices = MockFirestoreServices();
    mockStorageServices = MockStorageServices();
    mockPortfolioRepository = MockPortfolioRepository();
    mockCloudMessagingServices = MockCloudMessagingServices();

    mockUser = MockUser();
    container = ProviderContainer(overrides: [
      authServicesProvider.overrideWithValue(mockAuthServices),
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
      storageServicesProvider.overrideWithValue(mockStorageServices),
      portfolioRepositoryProvider.overrideWithValue(mockPortfolioRepository),
      cloudMessagingServicesProvider
          .overrideWithValue(mockCloudMessagingServices)
    ]);

    when(mockUser.emailVerified).thenReturn(true);
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
      expect(
          () => userRepository.createUser(username, email, password),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('username-taken'))));
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
      expect(
          () => userRepository.createUser(username, email, password),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('sign-up-error'))));
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
      when(mockFirestoreServices.addUser(any))
          .thenThrow(AppException('add-user-error'));
      when(mockAuthServices.deleteUser()).thenAnswer((_) async {});
      final userRepository = container.read(userRepositoryProvider);

      //Expect unexpected-error to be caught
      expect(
          () => userRepository.createUser(username, email, password),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('add-user-error'))));

      // verify(mockAuthServices.deleteUser()).called(1);
    });
  });

  group('signIn', () {
    test('signs in successfully', () async {
      const email = 'testEmail@email.com';
      const password = 'testPassword';

      when(mockAuthServices.signIn(email: email, password: password))
          .thenAnswer((_) async {});
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value('uid'));
      when(mockFirestoreServices.getUser()).thenAnswer((_) => Future.value(
          UserModel(
              uid: 'uid',
              email: email,
              username: email,
              isProfessional: false)));
      when(mockFirestoreServices.addUser(any)).thenAnswer((_) async {});
      when(mockUser.uid).thenReturn('uid');
      when(mockUser.email).thenReturn(email);

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.signIn(email, password), completes);

      verify(mockAuthServices.signIn(email: email, password: password))
          .called(1);
    });

    test('throws wrong-password when sign in credentials are incorrect',
        () async {
      const email = 'testEmail@email.com';
      const password = 'WrongPassword';

      when(mockAuthServices.signIn(email: email, password: password))
          .thenThrow(AppException('wrong-password'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
          () => userRepository.signIn(email, password),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('wrong-password'))));
    });
  });

  group('signOut', () {
    test('signs out successfully', () async {
      when(mockCloudMessagingServices.removeToken()).thenAnswer((_) async {});
      when(mockAuthServices.signOut()).thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.signOut(), completes);

      verify(mockAuthServices.signOut()).called(1);
    });

    test('throws error when sign out fails', () async {
      when(mockCloudMessagingServices.removeToken()).thenAnswer((_) async {});
      when(mockAuthServices.signOut())
          .thenThrow(AppException('sign-out-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
          () => userRepository.signOut(),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('sign-out-error'))));
    });

    test('signs out if token removal fails', () async {
      when(mockCloudMessagingServices.removeToken())
          .thenThrow(AppException('remove-token-error'));
      when(mockAuthServices.signOut()).thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(userRepository.signOut(), completes);

      verify(mockAuthServices.signOut()).called(1);
    });
  });

  group('updateProfile', () {
    test('updates profile with new profile picture and fields', () async {
      final mockFile = File('test_path');
      const downloadUrl = 'https://example.com/profile.jpg';
      final fieldsToUpdate = {'username': 'newUsername'};

      when(mockStorageServices.uploadProfilePicture(mockFile))
          .thenAnswer((_) async => downloadUrl);
      when(mockFirestoreServices.updateUser(
              {'profilePictureUrl': downloadUrl, 'username': 'newUsername'}))
          .thenAnswer((_) async {});

      final userRepository = container.read(userRepositoryProvider);
      await expectLater(
          userRepository.updateProfile(
              profilePicture: mockFile, fields: fieldsToUpdate),
          completes);

      verify(mockStorageServices.uploadProfilePicture(mockFile)).called(1);
      verify(mockFirestoreServices.updateUser(
              {'profilePictureUrl': downloadUrl, 'username': 'newUsername'}))
          .called(1);
    });

    test('throws error when update fails', () async {
      final fieldsToUpdate = {'username': 'newUsername'};

      when(mockFirestoreServices.updateUser(fieldsToUpdate))
          .thenThrow(AppException('update-profile-failed'));
      final userRepository = container.read(userRepositoryProvider);

      expect(
          () => userRepository.updateProfile(fields: fieldsToUpdate),
          throwsA(predicate((e) =>
              e is AppException &&
              e.toString().contains('update-profile-failed'))));
    });
  });

  group('reauthenticateUser', () {
    test('reauthenticates user successfully', () async {
      when(mockAuthServices.reauthenticateUser('password123'))
          .thenAnswer((_) async => {});

      final userRepository = container.read(userRepositoryProvider);
      await userRepository.reauthenticateUser('password123');

      verify(mockAuthServices.reauthenticateUser('password123')).called(1);
    });

    test('throws reauthenticate-user-error on reauthentication failure',
        () async {
      when(mockAuthServices.reauthenticateUser('password123'))
          .thenThrow(AppException('reauthenticate-user-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.reauthenticateUser('password123'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'reauthenticate-user-error')),
      );
    });
  });

  group('changeUserEmail', () {
    test('changes user email successfully', () async {
      when(mockAuthServices.updateEmail('new@example.com'))
          .thenAnswer((_) async => {});

      final userRepository = container.read(userRepositoryProvider);
      await userRepository.changeUserEmail('new@example.com');

      verify(mockAuthServices.updateEmail('new@example.com')).called(1);
    });

    test('throws update-email-error on email update failure', () async {
      when(mockAuthServices.updateEmail('new@example.com'))
          .thenThrow(AppException('update-email-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.changeUserEmail('new@example.com'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'update-email-error')),
      );
    });
  });

  group('updateUserPassword', () {
    test('updates user password successfully', () async {
      when(mockAuthServices.updatePassword('newPassword'))
          .thenAnswer((_) async => {});
      final userRepository = container.read(userRepositoryProvider);
      await userRepository.updateUserPassword('newPassword');

      verify(mockAuthServices.updatePassword('newPassword')).called(1);
    });

    test('throws update-password-error on password update failure', () async {
      when(mockAuthServices.updatePassword('newPassword123'))
          .thenThrow(AppException('update-password-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.updateUserPassword('newPassword123'),
        throwsA(predicate(
            (e) => e is AppException && e.code == 'update-password-error')),
      );
    });
  });

  group('deleteUserAccount', () {
    test('successfully deletes professional user with profile picture',
        () async {
      final userWithPortfolio = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: true,
          profilePictureUrl: 'https://example.com/photo.jpg');

      when(mockFirestoreServices.getUser())
          .thenAnswer((_) async => userWithPortfolio);

      // Mock portfolio deletion
      when(mockPortfolioRepository.deletePortfolio())
          .thenAnswer((_) async => {});

      // Mock other service calls
      when(mockStorageServices.deleteImage('profile_pictures/test-uid'))
          .thenAnswer((_) async => {});
      when(mockFirestoreServices.deleteUser()).thenAnswer((_) async => {});
      when(mockAuthServices.deleteUser()).thenAnswer((_) async => {});
      when(mockAuthServices.signOut()).thenAnswer((_) async => {});

      final repository = container.read(userRepositoryProvider);
      await repository.deleteUserAccount();

      verify(mockFirestoreServices.getUser()).called(1);
      verify(mockPortfolioRepository.deletePortfolio()).called(1);
      verify(mockStorageServices.deleteImage('profile_pictures/test-uid'))
          .called(1);
      verify(mockFirestoreServices.deleteUser()).called(1);
      verify(mockAuthServices.deleteUser()).called(1);
      verify(mockAuthServices.signOut()).called(1);
    });

    test('successfully deletes regular user without profile picture', () async {
      final regularUser = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: false,
          profilePictureUrl: null);

      when(mockFirestoreServices.getUser())
          .thenAnswer((_) async => regularUser);

      when(mockFirestoreServices.deleteUser()).thenAnswer((_) async => {});
      when(mockAuthServices.deleteUser()).thenAnswer((_) async => {});
      when(mockAuthServices.signOut()).thenAnswer((_) async => {});

      final repository = container.read(userRepositoryProvider);
      await repository.deleteUserAccount();

      verify(mockFirestoreServices.getUser()).called(1);
      verifyNever(mockPortfolioRepository.deletePortfolio());
      verifyNever(mockStorageServices.deleteImage(any));
      verify(mockFirestoreServices.deleteUser()).called(1);
      verify(mockAuthServices.deleteUser()).called(1);
      verify(mockAuthServices.signOut()).called(1);
    });

    test('throws AppException when user is not found', () async {
      when(mockFirestoreServices.getUser()).thenAnswer((_) async => null);

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('no-user'))),
      );
    });

    test('throws AppException when portfolio deletion fails', () async {
      final userWithPortfolio = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: true,
          profilePictureUrl: 'https://example.com/photo.jpg');

      when(mockFirestoreServices.getUser())
          .thenAnswer((_) async => userWithPortfolio);

      when(mockPortfolioRepository.deletePortfolio())
          .thenThrow(AppException('delete-portfolio-error'));

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-portfolio-error'))),
      );
    });

    test('throws AppException when profile picture deletion fails', () async {
      final userWithPhoto = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: false,
          profilePictureUrl: 'https://example.com/photo.jpg');

      when(mockFirestoreServices.getUser())
          .thenAnswer((_) async => userWithPhoto);

      when(mockStorageServices.deleteImage('profile_pictures/test-uid'))
          .thenThrow(AppException('delete-image-error'));

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('delete-image-error'))),
      );
    });

    test('throws AppException when user document deletion fails', () async {
      final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: false,
          profilePictureUrl: null);

      when(mockFirestoreServices.getUser()).thenAnswer((_) async => user);

      when(mockFirestoreServices.deleteUser())
          .thenThrow(AppException('delete-user-doc-error'));

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-user-doc-error'))),
      );
    });

    test('throws AppException when auth user deletion fails', () async {
      final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          username: 'testuser',
          isProfessional: false,
          profilePictureUrl: null);

      when(mockFirestoreServices.getUser()).thenAnswer((_) async => user);

      when(mockFirestoreServices.deleteUser()).thenAnswer((_) async => {});

      when(mockAuthServices.deleteUser())
          .thenThrow(AppException('delete-auth-user-error'));

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-auth-user-error'))),
      );
    });

    test('throws AppException for unexpected errors', () async {
      when(mockFirestoreServices.getUser())
          .thenThrow(Exception('Unexpected error'));

      final repository = container.read(userRepositoryProvider);
      expect(
        () => repository.deleteUserAccount(),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('delete-user-error'))),
      );
    });
  });

  group('sendEmailVerification', () {
    test('sends email verification successfully', () async {
      when(mockAuthServices.sendVerificationEmail())
          .thenAnswer((_) async => {});

      final userRepository = container.read(userRepositoryProvider);
      await userRepository.sendEmailVerification();

      verify(mockAuthServices.sendVerificationEmail()).called(1);
    });

    test('throws email-verification-error when sending verification fails',
        () async {
      when(mockAuthServices.sendVerificationEmail())
          .thenThrow(Exception('Failed to send verification email'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.sendEmailVerification(),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('email-verification-error'))),
      );
    });

    test('rethrows AppException from auth service', () async {
      when(mockAuthServices.sendVerificationEmail())
          .thenThrow(AppException('already-verified'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.sendEmailVerification(),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('already-verified'))),
      );
    });
  });

  group('verifyPhone', () {
    test('verifies phone number successfully', () async {
      const phoneNumber = '+1234567890';
      const verificationId = 'test-verification-id';
      when(mockAuthServices.verifyPhoneNumber(phoneNumber))
          .thenAnswer((_) async => verificationId);

      final userRepository = container.read(userRepositoryProvider);
      final result = await userRepository.verifyPhone(phoneNumber);

      expect(result, equals(verificationId));
      verify(mockAuthServices.verifyPhoneNumber(phoneNumber)).called(1);
    });

    test('throws verify-number-error when verification fails', () async {
      const phoneNumber = '+1234567890';
      when(mockAuthServices.verifyPhoneNumber(phoneNumber))
          .thenThrow(Exception('Failed to verify phone number'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.verifyPhone(phoneNumber),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('verify-number-error'))),
      );
    });

    test('rethrows AppException from auth service', () async {
      const phoneNumber = '+1234567890';
      when(mockAuthServices.verifyPhoneNumber(phoneNumber))
          .thenThrow(AppException('custom-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.verifyPhone(phoneNumber),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('custom-error'))),
      );
    });
  });

  group('verifySmsCode', () {
    test('verifies SMS code successfully', () async {
      const verificationId = 'test-verification-id';
      const smsCode = '123456';
      when(mockAuthServices.verifySmsCode(verificationId, smsCode))
          .thenAnswer((_) async => {});

      final userRepository = container.read(userRepositoryProvider);
      await userRepository.verifySmsCode(verificationId, smsCode);

      verify(mockAuthServices.verifySmsCode(verificationId, smsCode)).called(1);
    });

    test('throws verify-sms-error when SMS verification fails', () async {
      const verificationId = 'test-verification-id';
      const smsCode = '123456';
      when(mockAuthServices.verifySmsCode(verificationId, smsCode))
          .thenThrow(Exception('Failed to verify SMS code'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.verifySmsCode(verificationId, smsCode),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('verify-sms-error'))),
      );
    });

    test('rethrows AppException from auth service', () async {
      const verificationId = 'test-verification-id';
      const smsCode = '123456';
      when(mockAuthServices.verifySmsCode(verificationId, smsCode))
          .thenThrow(AppException('custom-error'));

      final userRepository = container.read(userRepositoryProvider);
      expect(
        () => userRepository.verifySmsCode(verificationId, smsCode),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('custom-error'))),
      );
    });
  });

  group('getOtherUser', () {
    test('successfully returns other user', () async {
      final otherUser = UserModel(
          uid: 'uid',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false);

      when(mockFirestoreServices.getOtherUser('uid'))
          .thenAnswer((_) async => otherUser);
      final userRepository = container.read(userRepositoryProvider);

      final result = await userRepository.getOtherUser('uid');

      expect(result, otherUser);
      verify(mockFirestoreServices.getOtherUser('uid')).called(1);
    });
    test('throws app exception when firestore getOtherUser fails', () async {
      when(mockFirestoreServices.getOtherUser('uid'))
          .thenThrow(Exception('error-error'));
      final userRepository = container.read(userRepositoryProvider);

      expect(
        () => userRepository.getOtherUser('uid'),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('get-other-user-error'))),
      );
    });
  });
}
