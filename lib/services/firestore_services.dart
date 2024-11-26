import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FirestoreServices(this._firestore, this._ref);

  ///////////////////////// USER COLLECTION /////////////////////////

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw AppException('add-user-error');
    }
  }

<<<<<<< HEAD
  Future<void> addService(String service) async {
    try {
      await _firestore.collection('services').doc(service).set({
        'service': service,
      });
    } catch (e) {
      throw AppException('add-service-error');
=======
  Future<UserModel?> getUser() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      try {
        return UserModel.fromJson(userDoc.data()!);
      } catch (e) {
        throw AppException('invalid-user-data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-user-error');
      }
>>>>>>> main
    }
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw AppException('no-user-doc');
      }
      try {
        return UserModel.fromJson(snapshot.data()!);
      } catch (e) {
        throw AppException('invalid-user-data');
      }
    }).handleError((error) {
      if (error is AppException) {
        throw error;
      } else {
        throw AppException('user-stream-error');
      }
    });
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw AppException('username-unique-error');
    }
  }

  Future<void> updateUser(Map<String, dynamic> fieldsToUpdate) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();
      await _firestore.collection('users').doc(uid).update(fieldsToUpdate);
    } catch (e) {
      throw AppException('update-user-error');
    }
  }

  Future<void> deleteUser() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }
      final documentRef = _firestore.collection('users').doc(uid);

      await documentRef.update({
        'completedOnboarding': FieldValue.delete(),
        'email': FieldValue.delete(),
        'fullName': FieldValue.delete(),
        'isProfessional': FieldValue.delete(),
        'preferredServices': FieldValue.delete(),
        'profilePictureUrl': FieldValue.delete(),
        'uid': FieldValue.delete(),
        'username': FieldValue.delete(),
      });
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-user-error');
      }
    }
  }

  ///////////////////////// PORTFOLIO COLLECTION /////////////////////////

  Future<PortfolioModel?> getPortfolio() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioDoc =
          await _firestore.collection('portfolios').doc(uid).get();

      if (!portfolioDoc.exists) {
        return null;
      }

      try {
        return PortfolioModel.fromJson(portfolioDoc.data()!);
      } catch (e) {
        throw AppException('invalid-portfolio-data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-portfolio-error');
      }
    }
  }

  Stream<PortfolioModel?> getPortfolioStream(String uid) {
    return _firestore
        .collection('portfolios')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      try {
        return PortfolioModel.fromJson(snapshot.data()!);
      } catch (e) {
        throw AppException('invalid-portfolio-data');
      }
    }).handleError((error) {
      if (error is AppException && error.code == 'invalid-portfolio-data') {
        throw error;
      } else {
        throw AppException('portfolio-stream-error');
      }
    });
  }

  Future<void> savePortfolioDetails(Map<String, dynamic> fieldsToUpdate) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioRef = _firestore.collection('portfolios').doc(uid);
      final portoflioDoc = await portfolioRef.get();

      if (portoflioDoc.exists) {
        if (fieldsToUpdate.containsKey('images')) {
          fieldsToUpdate['images'] =
              FieldValue.arrayUnion(fieldsToUpdate['images']);
        }
        await portfolioRef.update(fieldsToUpdate);
      } else {
        await portfolioRef.set(fieldsToUpdate);
      }
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('update-portfolio-error');
      }
    }
  }

  Future<void> deletePortfolioImage(String filePath, String downloadUrl) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioRef = _firestore.collection('portfolios').doc(uid);

      await portfolioRef.update({
        'images': FieldValue.arrayRemove([
          {
            'filePath': filePath,
            'downloadUrl': downloadUrl,
          }
        ])
      });
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-portfolio-image-error');
      }
    }
  }

  Future<void> deletePortfolio() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      await _firestore.collection('portfolios').doc(uid).delete();
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-portfolio-error');
      }
    }
  }

  ///////////////////////// SERVICE COLLECTION /////////////////////////

  Future<List<String>> getServices() async {
    try {
      final QuerySnapshot servicesSnapshot =
          await _firestore.collection('services').get();

      List<String> servicesList = servicesSnapshot.docs
          .map((doc) => doc.get('service') as String)
          .toList();
      return servicesList;
    } catch (e) {
      throw AppException('get-services-error');
    }
  }

  ///////////////////////// FEEDBACK COLLECTION /////////////////////////
  Future<void> addFeedback(FeedbackModel feedbackModel) async {
    try {
      await _firestore
          .collection('feedback')
          .doc(feedbackModel.id)
          .set(feedbackModel.toJson());
    } catch (e) {
      throw AppException('add-feedback-error');
    }
  }
}
