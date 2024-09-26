import 'package:senior_final_project/models/user_model.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

class UserRepository {
  final AuthServices _authServices;
  final UserFirestoreServices _userFirestoreServices;

  UserRepository(this._authServices, this._userFirestoreServices);

  Future<void> createUser(
      String username, String email, String password) async {
    try {
      bool usernameIsUnique =
          await _userFirestoreServices.isUsernameUnique(username);

      if (!usernameIsUnique) {
        throw 'username-taken';

      }

        final result = await _authServices.signUp(email: email, password: password);

        if (result != null) {

          final user = UserModel(
              uid: result,
              username: username,
              email: email,
              isProfessional: false);

          await _userFirestoreServices.addUser(user);
        }
    
    } catch (e) {
      rethrow;
    }
  }
}
