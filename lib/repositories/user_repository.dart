import 'dart:io';

import 'package:folio/core/app_exception.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

class UserRepository {
  final AuthServices _authServices;
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;

  UserRepository(this._authServices, this._firestoreServices,
      this._storageServices);

  Future<void> createUser(
      String username, String email, String password) async {
    try {
      bool usernameIsUnique =
          await _firestoreServices.isUsernameUnique(username);
      if (!usernameIsUnique) {
        throw AppException('username-taken');
      }
      final result = await _authServices.signUp(
          email: email, password: password, username: username);

      if (result == null) {
        throw AppException('sign-up-error');
      }
      final user = UserModel(
          uid: result, username: username, email: email, isProfessional: false);

      await _firestoreServices.addUser(user);

      await _authServices.sendVerificationEmail();
    } catch (e) {
      if (e is AppException) {
        if (e.code == "add-user-error") {
          await _authServices.deleteUser();
        }
        rethrow;
      } else {
        throw AppException('create-user-error');
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authServices.signIn(email: email, password: password);
    } catch (e) {
      if (e is AppException) {
        rethrow; // Let AppExceptions propagate
      } else {
        throw AppException('sign-in-error');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _authServices.signOut();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('sign-out-error');
      }
    }
  }

  Future<void> updateProfile(
      {File? profilePicture, Map<String, dynamic>? fields}) async {
    try {
      final fieldsToUpdate = <String, dynamic>{};

      if (fields != null && fields.containsKey('profilePictureUrl') && fields['profilePictureUrl'] == null) {
        final currentUserUid = await _authServices.currentUserUid();

         await _storageServices.deleteImage('profile_pictures/$currentUserUid'); 
         fieldsToUpdate.addAll(fields);
        
      } else if(fields != null && fields.isNotEmpty){
        fieldsToUpdate.addAll(fields);
      }
      
      if (profilePicture != null) {
        final downloadUrl =
            await _storageServices.uploadProfilePicture(profilePicture);
        if (downloadUrl != null) {
          fieldsToUpdate['profilePictureUrl'] = downloadUrl;
        }
      }

      if (fieldsToUpdate.isNotEmpty) {
        await _firestoreServices.updateUser(fieldsToUpdate);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('update-profile-error');
      }
    }
  }

    Future<void> reauthenticateUser(String password) async {
    await _authServices.reauthenticateUser(password);
  }

  Future<void> changeUserEmail(String newEmail) async {
    await _authServices.updateEmail(newEmail);
  }
}
