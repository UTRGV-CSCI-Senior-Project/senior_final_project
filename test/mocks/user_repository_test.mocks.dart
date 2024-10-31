// Mocks generated by Mockito 5.4.4 from annotations
// in folio/test/unit/repositories/user_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:io' as _i9;

import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:folio/models/portfolio_model.dart' as _i7;
import 'package:folio/models/user_model.dart' as _i6;
import 'package:folio/services/auth_services.dart' as _i2;
import 'package:folio/services/firestore_services.dart' as _i5;
import 'package:folio/services/storage_services.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;

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
    required String? username,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUp,
          [],
          {
            #email: email,
            #password: password,
            #username: username,
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

  @override
  _i3.Future<void> sendVerificationEmail() => (super.noSuchMethod(
        Invocation.method(
          #sendVerificationEmail,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [FirestoreServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirestoreServices extends _i1.Mock implements _i5.FirestoreServices {
  MockFirestoreServices() {
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
  _i3.Stream<_i6.UserModel> getUserStream(String? uid) => (super.noSuchMethod(
        Invocation.method(
          #getUserStream,
          [uid],
        ),
        returnValue: _i3.Stream<_i6.UserModel>.empty(),
      ) as _i3.Stream<_i6.UserModel>);

  @override
  _i3.Stream<_i7.PortfolioModel?> getPortfolioStream(String? uid) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPortfolioStream,
          [uid],
        ),
        returnValue: _i3.Stream<_i7.PortfolioModel?>.empty(),
      ) as _i3.Stream<_i7.PortfolioModel?>);

  @override
  _i3.Future<bool> isUsernameUnique(String? username) => (super.noSuchMethod(
        Invocation.method(
          #isUsernameUnique,
          [username],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<void> updateUser(Map<String, dynamic>? fieldsToUpdate) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUser,
          [fieldsToUpdate],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<List<String>> getServices() => (super.noSuchMethod(
        Invocation.method(
          #getServices,
          [],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  _i3.Future<void> savePortfolioDetails(Map<String, dynamic>? fieldsToUpdate) =>
      (super.noSuchMethod(
        Invocation.method(
          #savePortfolioDetails,
          [fieldsToUpdate],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deletePortfolioImage(
    String? filePath,
    String? downloadUrl,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deletePortfolioImage,
          [
            filePath,
            downloadUrl,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deletePortfolio() => (super.noSuchMethod(
        Invocation.method(
          #deletePortfolio,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [StorageServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorageServices extends _i1.Mock implements _i8.StorageServices {
  MockStorageServices() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<String?> uploadProfilePicture(_i9.File? image) =>
      (super.noSuchMethod(
        Invocation.method(
          #uploadProfilePicture,
          [image],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<List<Map<String, String>>> uploadFilesForUser(
          List<_i9.File>? files) =>
      (super.noSuchMethod(
        Invocation.method(
          #uploadFilesForUser,
          [files],
        ),
        returnValue: _i3.Future<List<Map<String, String>>>.value(
            <Map<String, String>>[]),
      ) as _i3.Future<List<Map<String, String>>>);

  @override
  _i3.Future<List<String>> fetchImagesForUser() => (super.noSuchMethod(
        Invocation.method(
          #fetchImagesForUser,
          [],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  _i3.Future<void> deleteImage(String? imagePath) => (super.noSuchMethod(
        Invocation.method(
          #deleteImage,
          [imagePath],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deletePortfolio() => (super.noSuchMethod(
        Invocation.method(
          #deletePortfolio,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
