import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_final_project/models/user_model.dart';
import 'package:senior_final_project/services/auth_services.dart';

class UserRepository {
  final db = FirebaseFirestore.instance;

  Future<void> createUser(
      String username, String email, String password) async {
    try {
      bool usernameIsUnique = await isUsernameUnique(username);

      if (usernameIsUnique) {
        final result =
            await AuthServices().signUp(email: email, password: password);

        if (result != null) {
          final user = UserModel(
              uid: result,
              username: username,
              email: email,
              isProfessional: false);
          try {
            await db.collection('users').add(user.toJson());
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

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }
}
