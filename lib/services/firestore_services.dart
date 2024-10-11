import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';


class FirestoreServices {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FirestoreServices(this._firestore, this._ref);

    Future<void> addUser(UserModel user) async {
      try{
        await _firestore.collection('users').doc(user.uid).set(user.toJson());
      } catch(e){
        throw 'unexpected-error';

      }
    }

    Future<UserModel?> getUser(String uid) async {
      try{
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if(docSnapshot.exists){
        return UserModel.fromJson(docSnapshot.data()!);
      }else {
        throw 'user-not-found';
      }
      }catch (e){
        if(e == 'user-not-found'){
          rethrow;
        }else{
        throw 'unexpected-error';

        }
      }
    }

    Stream<UserModel> getUserStream(String uid) {
      return _firestore.collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
    }


    Future<bool> isUsernameUnique(String username) async {
      try{
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
      }catch (e){
        throw 'unexpected-error';
      }

  }

  Future<void> updateUser(Map<String, dynamic> fieldsToUpdate) async {
    try{
      final uid = _ref.read(authStateProvider).value?.uid;
      await _firestore.collection('users').doc(uid).update(fieldsToUpdate);
    }catch(e){
      throw 'update-failed';
    }
  }

  Future<List<String>> getServices() async {
    try{
      final QuerySnapshot servicesSnapshot = await _firestore.collection('services').get();

      List<String> servicesList = servicesSnapshot.docs.map((doc) => doc.get('service') as String).toList();
      return servicesList;
    } catch (e){
      throw 'unexpected-error';
    }
  }
}