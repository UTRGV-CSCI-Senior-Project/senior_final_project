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
      
      throw e.code;
    } catch (e) {
      throw "unexpected-error";
    }
  }
}
