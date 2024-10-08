import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/user_firestore_services.dart';

class UserRepository {
  final AuthServices _authServices;
  final UserFirestoreServices _userFirestoreServices;
  final Ref _ref;

  UserRepository(this._authServices, this._userFirestoreServices, this._ref);

  Future<void> createUser(
      String username, String email, String password) async {
    try {
      bool usernameIsUnique =
          await _userFirestoreServices.isUsernameUnique(username);
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
          await _userFirestoreServices.addUser(user);

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
}
