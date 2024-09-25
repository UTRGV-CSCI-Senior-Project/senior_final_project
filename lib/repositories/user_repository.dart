import 'package:senior_final_project/models/user_model.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

class UserRepository {

  final AuthServices _authServices;
  final UserFirestoreServices _userFirestoreServices;

  UserRepository({
    AuthServices? authServices,
    UserFirestoreServices? userFirestoreServices,
  }) : _authServices = authServices ?? AuthServices(),
       _userFirestoreServices = userFirestoreServices ?? UserFirestoreServices();
  

  Future<void> createUser(String username, String email, String password) async {
    try {
      bool usernameIsUnique = await _userFirestoreServices.isUsernameUnique(username);

      if (usernameIsUnique) {
        final result =
            await _authServices.signUp(email: email, password: password);

        if (result != null) {
          final user = UserModel(
              uid: result,
              username: username,
              email: email,
              isProfessional: false);
          try {
            await _userFirestoreServices.addUser(user);
          } catch (e) {
            throw Exception('An error ocurred. Try again later');
          }
        }
      } else {
        throw Exception('Username is already taken');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  
}
