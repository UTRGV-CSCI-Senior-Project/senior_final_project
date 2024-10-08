// Mocks generated by Mockito 5.4.4 from annotations
// in senior_final_project/test/unit/repositories/user_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:senior_final_project/models/user_model.dart' as _i6;
import 'package:senior_final_project/services/auth_services.dart' as _i2;
import 'package:senior_final_project/services/user_firestore_services.dart'
    as _i5;

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

/// A class which mocks [AuthServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthServices extends _i1.Mock implements _i2.AuthServices {
  MockAuthServices() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<String?> signUp({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUp,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<void> signIn({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
          {
            #email: email,
            #password: password,
          },
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
  _i3.Stream<_i4.User?> authStateChanges() => (super.noSuchMethod(
        Invocation.method(
          #authStateChanges,
          [],
        ),
        returnValue: _i3.Stream<_i4.User?>.empty(),
      ) as _i3.Stream<_i4.User?>);

  @override
  _i3.Future<void> deleteUser() => (super.noSuchMethod(
        Invocation.method(
          #deleteUser,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [UserFirestoreServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserFirestoreServices extends _i1.Mock
    implements _i5.UserFirestoreServices {
  MockUserFirestoreServices() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> addUser(_i6.UserModel? user) => (super.noSuchMethod(
        Invocation.method(
          #addUser,
          [user],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<_i6.UserModel?> getUser(String? uid) => (super.noSuchMethod(
        Invocation.method(
          #getUser,
          [uid],
        ),
        returnValue: _i3.Future<_i6.UserModel?>.value(),
      ) as _i3.Future<_i6.UserModel?>);

  @override
  _i3.Future<bool> isUsernameUnique(String? username) => (super.noSuchMethod(
        Invocation.method(
          #isUsernameUnique,
          [username],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
