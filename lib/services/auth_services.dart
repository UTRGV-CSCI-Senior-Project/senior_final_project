import 'dart:async';

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

  Stream<User?> userChanges() {
    return _firebaseAuth.userChanges();
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

  Future<void> reauthenticateUser(String password) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AppException('no-user');
      }

      final currentEmail = user.email;
      if (currentEmail == null) {
        throw AppException('no-email');
      }

      final credential =
          EmailAuthProvider.credential(email: currentEmail, password: password);

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('reauthenticate-error');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AppException('no-user');
      }
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('update-email-error');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AppException('no-user');
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.code.toString());
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('update-password-error');
    }
  }

  Future<String> verifyPhoneNumber(String phoneNumber) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AppException('no-user');
    }
    try {
      final Completer<String> completer = Completer();

      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await user.updatePhoneNumber(credential);
            } catch (e) {
              if (e is FirebaseAuthException) {
                throw AppException(e.code);
              } else {
                throw AppException('phone-number-update-failed');
              }
            }
          },
          verificationFailed: (FirebaseAuthException exception) {
            throw AppException(exception.code);
          },
          codeAutoRetrievalTimeout: (_) {},
          codeSent: (String verificationId, int? resendToken) async {
            completer.complete(verificationId); // Complete with the verification ID
          });
      return await completer.future; // Return the verification ID
    } catch (e) {
      if(e is FirebaseAuthException){
        throw AppException(e.code);
      }else if (e is AppException) {
        rethrow;
      } else {
        throw AppException('verify-number-error');
      }
    }
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AppException('no-user');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      try {
        await user.updatePhoneNumber(credential);
      } catch (e) {
        if(e is FirebaseAuthException){
        throw AppException(e.code);
      }else if (e is AppException) {
          rethrow;
        } else {
          throw AppException('verify-sms-error');
        }
      }
    } catch (e) {
      if(e is FirebaseAuthException){
        throw AppException(e.code);
      }else if (e is AppException) {
        rethrow;
      } else {
        throw AppException('verify-sms-error');
      }
    }
  }
}
