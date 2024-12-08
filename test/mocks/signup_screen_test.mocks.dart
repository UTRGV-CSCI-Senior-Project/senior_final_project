// Mocks generated by Mockito 5.4.4 from annotations
// in folio/test/views/auth_onboarding_welcome/signup_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:io' as _i4;

import 'package:folio/models/user_model.dart' as _i6;
import 'package:folio/repositories/user_repository.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [UserRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserRepository extends _i1.Mock implements _i2.UserRepository {
  MockUserRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> createUser(
    String? username,
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createUser,
          [
            username,
            email,
            password,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> signIn(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [
            email,
            password,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> updateProfile({
    _i4.File? profilePicture,
    Map<String, dynamic>? fields,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateProfile,
          [],
          {
            #profilePicture: profilePicture,
            #fields: fields,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> reauthenticateUser(String? password) => (super.noSuchMethod(
        Invocation.method(
          #reauthenticateUser,
          [password],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> changeUserEmail(String? newEmail) => (super.noSuchMethod(
        Invocation.method(
          #changeUserEmail,
          [newEmail],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> updateUserPassword(String? newPassword) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUserPassword,
          [newPassword],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deleteUserAccount() => (super.noSuchMethod(
        Invocation.method(
          #deleteUserAccount,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> sendEmailVerification() => (super.noSuchMethod(
        Invocation.method(
          #sendEmailVerification,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<String> verifyPhone(String? phoneNumber) => (super.noSuchMethod(
        Invocation.method(
          #verifyPhone,
          [phoneNumber],
        ),
        returnValue: _i3.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #verifyPhone,
            [phoneNumber],
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<void> verifySmsCode(
    String? verificationId,
    String? smsCode,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifySmsCode,
          [
            verificationId,
            smsCode,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<_i6.UserModel?> getOtherUser(String? uid) => (super.noSuchMethod(
        Invocation.method(
          #getOtherUser,
          [uid],
        ),
        returnValue: _i3.Future<_i6.UserModel?>.value(),
      ) as _i3.Future<_i6.UserModel?>);
}
