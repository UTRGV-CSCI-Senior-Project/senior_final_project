import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

class UserRepository {
  final AuthServices _authServices;
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;
  final Ref _ref;

  UserRepository(this._authServices, this._firestoreServices, this._storageServices, this._ref);

  Future<void> createUser(
      String username, String email, String password) async {
    try {
      bool usernameIsUnique =
          await _firestoreServices.isUsernameUnique(username);
      if (!usernameIsUnique) {
        throw 'username-taken';
      }
      final result =
          await _authServices.signUp(email: email, password: password, username: username);
      if (result != null) {
        final user = UserModel(
            uid: result,
            username: username,
            email: email,
            isProfessional: false);

        try {
          await _firestoreServices.addUser(user);

        } catch (e) {
          await _authServices.deleteUser();
          throw 'firestore-add-fail';
        }

        _authServices.sendVerificationEmail();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authServices.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authServices.signOut();
  }

  Future<void> updateProfile({File? profilePicture, Map<String, dynamic>? fields}) async {
    try{
      final fieldsToUpdate = <String, dynamic>{};

      if(fields != null && fields.isNotEmpty){
        fieldsToUpdate.addAll(fields);
      }

      if(profilePicture != null){
        final downloadUrl = await _storageServices.uploadProfilePicture(profilePicture);
        if(downloadUrl != null){
          fieldsToUpdate['profilePictureUrl'] = downloadUrl;
        }
      }

      if(fieldsToUpdate.isNotEmpty){
        await _firestoreServices.updateUser(fieldsToUpdate);
      }

    }catch (e) {
      rethrow;
    }

  }
}
