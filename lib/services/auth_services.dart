import 'package:firebase_auth/firebase_auth.dart';
import 'package:folio/core/app_exception.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth;

  AuthServices(this._firebaseAuth);

  Future<String?> signUp(
      {required String email,
      required String password,
      required String username}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await credential.user?.updateDisplayName(username);
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      throw AppException('sign-up-error');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      throw AppException('sign-in-error');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AppException('sign-out-error');
    }
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      throw AppException('delete-user-error');
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      if (_firebaseAuth.currentUser == null) {
        throw AppException('no-user');
      }
      if (_firebaseAuth.currentUser?.emailVerified == false) {
        await _firebaseAuth.currentUser?.sendEmailVerification();
      } else {
        throw AppException('already-verified');
      }
    } catch (e) {
      if (e is AppException &&
          (e.code == 'no-user' || e.code == 'already-verified')) {
        rethrow;
      } else {
        throw AppException('email-verification-error');
      }
    }
  }

  Future<String?> currentUserUid() async {
    return _firebaseAuth.currentUser?.uid;
}

}
