import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth;

  AuthServices({FirebaseAuth? firebaseAuth})
  :_firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;


  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists for that email.";
      } else {
        errorMessage = "An error ocurred. Try again later";
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error ocurred. Try again later");
    }
  }
}
