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

 Future<List<Object?>> getUser(String uid) async {
  try {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      final user = UserModel.fromJson(docSnapshot.data()!);

      if (user.isProfessional) {
        final docSnap = await _firestore.collection('portfolio').doc(uid).get();
        if (docSnap.exists) {
          final portfolio = PortfolioModel.fromJson(docSnap.data()!);
          return [user, portfolio];
        } else {
          return [user, null];  // If no portfolio, return null for PortfolioModel
        }
      }

      return [user, null];  // Return null for PortfolioModel if not a professional
    } else {
      throw 'user-not-found';
    }
  } catch (e) {
    if (e == 'user-not-found') {
      rethrow;
    } else {
      throw 'unexpected-error';
    }
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

  Future<PortfolioModel?> getPortfolio(String uid) async {
     try {
      final docSnapshot = await _firestore.collection('portfolios').doc(uid).get();
      if (docSnapshot.exists) {
        return PortfolioModel.fromJson(docSnapshot.data()!); // Assuming PortfolioModel
      } else {
        throw 'portfolio-not-found';
      }
    } catch (e) {
      if (e == 'portfolio-not-found') {
        rethrow;
      } else {
        throw 'unexpected-error';
      }
    }
  }

  Future<Map<String, dynamic>> getUserAndPortfolio(String uid) async {
    try {
      // Fetch both user and portfolio data in parallel
      final results = await Future.wait([
        getUser(uid), // User data
        getPortfolio(uid), // Portfolio data
      ]);

      // Extract the user and portfolio data from the results
      final user = results[0] as UserModel?;
      final portfolio = results[1] as PortfolioModel?;

      if (user == null || portfolio == null) {
        throw 'data-not-found';
      }

      // Return a combined result (user + portfolio)
      return {
        'user': user,
        'portfolio': portfolio,
      };
    } catch (e) {
      throw 'unexpected-error';
    }
  }

  Future<List<Map<String, dynamic>>> getAllPortfoliosWithUsers() async {
    try {
      print('called');
      // Step 1: Get all portfolios
      final portfoliosSnapshot = await _firestore.collection('portfolio').get();
    
      // Step 2: For each portfolio, fetch the corresponding user
      List<Map<String, dynamic>> portfolioUserList = [];
      
      for (var portfolioDoc in portfoliosSnapshot.docs) {
        final uid = portfolioDoc.id;
        // Fetch user data for the given uid
        final user = await getUser(uid);
        final portfolio = PortfolioModel.fromJson(portfolioDoc.data());

        // Only add to the list if the user exists
        if (user != null) {
          portfolioUserList.add({
            'user': user,
            'portfolio': portfolio,
          });
        }
      }
      return portfolioUserList;
    } catch (e) {
      throw 'unexpected-error';
    }
  }


}
