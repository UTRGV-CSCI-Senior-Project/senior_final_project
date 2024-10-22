import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FirestoreServices(this._firestore, this._ref);

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw 'unexpected-error';
    }
  }


  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw 'no-user';
      }
      try {
        return UserModel.fromJson(snapshot.data()!);
      } catch (e) {
        throw 'invalid-user-data';
      }
    }).handleError((error) {
      if(error == 'no-user' || error == 'invalid-user-data')
      {
        throw error;
      }else{
        throw 'unexpected-error';
      }
    });
  }

  Stream<PortfolioModel?> getPortfolioStream(String uid) {
    return _firestore.collection('portfolios').doc(uid).snapshots().map((snapshot) {
      if(!snapshot.exists){
        return null;
      }try{
        return PortfolioModel.fromJson(snapshot.data()!);
      }catch (e){
        throw 'invalid-portfolio-data';
      }
    }).handleError((error) {
    if (error == 'invalid-user-data') {
        throw error;
      } else {
        throw 'unexpected-error';
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
      throw 'unexpected-error';
    }
  }

  Future<void> updateUser(Map<String, dynamic> fieldsToUpdate) async {
    try {
      final uid = _ref.read(authStateProvider).value?.uid;
      await _firestore.collection('users').doc(uid).update(fieldsToUpdate);
    } catch (e) {
      throw 'update-failed';
    }
  }

  Future<List<String>> getServices() async {
    try {
      final QuerySnapshot servicesSnapshot =
          await _firestore.collection('services').get();

      List<String> servicesList = servicesSnapshot.docs
          .map((doc) => doc.get('service') as String)
          .toList();
      return servicesList;
    } catch (e) {
      throw 'unexpected-error';
    }
  }


  Future<void> savePortfolioDetails(Map<String, dynamic> fieldsToUpdate) async {
  try {
    final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw 'no-user';
      }

    final portfolioRef =  _firestore.collection('portfolios').doc(uid);
    final portoflioDoc = await portfolioRef.get();

    if(portoflioDoc.exists){
      if(fieldsToUpdate.containsKey('images')){
        fieldsToUpdate['images'] = FieldValue.arrayUnion(fieldsToUpdate['images']);
      }
      await portfolioRef.update(fieldsToUpdate);

    }else{
      await portfolioRef.set(fieldsToUpdate);
    }

  } catch (e) {
    throw 'update-failed';
  }
}

Future<void> deletePortfolioImage(String filePath, String downloadUrl) async {
  try {
    final uid = _ref.read(authStateProvider).value?.uid;

    if (uid == null) {
      throw 'no-user';
    }

    final portfolioRef = _firestore.collection('portfolios').doc(uid);

    await portfolioRef.update({
      'images': FieldValue.arrayRemove([{
        'filePath': filePath,
        'downloadUrl': downloadUrl,
      }])
    });
  } catch (e) {
    throw 'delete-failed';
  }
}

Future<void> deletePortfolio() async {
  try{
    final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw 'no-user';
      }

    await _firestore.collection('portfolios').doc(uid).delete();

  } catch (e){
    throw 'unexpected-error';
  }
}


}
