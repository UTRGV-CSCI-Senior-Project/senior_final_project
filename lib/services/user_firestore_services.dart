import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_final_project/models/user_model.dart';


class UserFirestoreServices {
  final FirebaseFirestore _firestore;

  UserFirestoreServices({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


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
}