import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth;

  AuthServices({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<String?> signUp(
      {required String email, required String password, required String username}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credential.user?.updateDisplayName(username);
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw e.code.toString();
    } catch (e) {
      throw "unexpected-error";
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.code.toString();
    } catch (e) {
      throw 'unexpected-error';
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'sign-out-error';
    }
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw e.code.toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendVerificationEmail() async {
    try{
      if(_firebaseAuth.currentUser == null)
      {
        throw 'no-user';
      }
      if(_firebaseAuth.currentUser?.emailVerified == false){
        await _firebaseAuth.currentUser?.sendEmailVerification();
      }else{
        throw 'already-verified';
      }
    }catch (e){
      if(e == 'already-verified' || e == 'no-user'){
        rethrow;
      }
      else{
        throw 'email-verification-error';
      }
    }
  }

}
