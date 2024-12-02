import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/cloud_messaging_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

class UserRepository {
  final AuthServices _authServices;
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;
  final CloudMessagingServices _cloudMessagingServices;
  final Ref _ref;

  UserRepository(
      this._authServices, this._firestoreServices, this._storageServices, this._ref, this._cloudMessagingServices);

  Future<void> createUser(
    String username,
    String email,
    String password,
  ) async {
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

      final userDoc = await _firestoreServices.getUser();
      final userUID = await _authServices.currentUserUid();

      if (userDoc == null && userUID != null) {
        await _firestoreServices.addUser(UserModel(
            uid: userUID,
            username: email.split('@')[0],
            email: email,
            isProfessional: false));
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('sign-in-error');
      }
    }
  }

  Future<void> signOut() async {
    try{
      await _cloudMessagingServices.removeToken();
    }catch(e){
    }

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

      if (fields != null &&
          fields.containsKey('profilePictureUrl') &&
          fields['profilePictureUrl'] == null) {
        final currentUserUid = await _authServices.currentUserUid();

        await _storageServices.deleteImage('profile_pictures/$currentUserUid');
        fieldsToUpdate.addAll(fields);
      } else if (fields != null && fields.isNotEmpty) {
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
    try{
    await _authServices.reauthenticateUser(password);
    }catch (e)
    {
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('reauthenticate-error');
      }
    }
  }

  Future<void> changeUserEmail(String newEmail) async {
    try{
    await _authServices.updateEmail(newEmail);
    }
    catch (e)
    {
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('update-email-error');
      }
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try{

    await _authServices.updatePassword(newPassword);
    }
    catch (e)
    {
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('update-password-error');
      }
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final user = await _firestoreServices.getUser();

      if (user == null) {
        throw AppException('no-user');
      }
      if (user.isProfessional) {
        await _ref.read(portfolioRepositoryProvider).deletePortfolio();
      }
      if (user.profilePictureUrl != null &&
          user.profilePictureUrl!.isNotEmpty) {
        await _storageServices.deleteImage('profile_pictures/${user.uid}');
      }

      await _firestoreServices.deleteUser();

      await _authServices.deleteUser();

      await _authServices.signOut();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('delete-user-error');
      }
    }
  }

  Future<void> sendEmailVerification() async {
    try{

    await _authServices.sendVerificationEmail();
    }catch (e)
    {
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('email-verification-error');
      }
    }
  }

  Future<String> verifyPhone(String phoneNumber) async {
    try {
      return await _authServices.verifyPhoneNumber(phoneNumber);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('verify-number-error');
      }
    }
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    try{
      await _authServices.verifySmsCode(verificationId, smsCode);
    }catch (e){
      if(e is AppException)
      {
        rethrow;
      }else{
        throw AppException('verify-sms-error');
      }
    }
  }
}
