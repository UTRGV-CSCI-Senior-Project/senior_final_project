import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folio/models/message_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';

class MessageRepository {
  final FirestoreServices _firestoreServices;
  final AuthServices _authServices;

  MessageRepository(this._firestoreServices, this._authServices);

  Future<void> sendMessage(String recieverId, String message)async{
    try{

    final senderId = await _authServices.currentUserUid();
    if(senderId != null){
      final Timestamp timestamp = Timestamp.now();
      final newMessage = MessageModel(senderId: senderId, recieverId: recieverId, message: message, timestamp: timestamp);
      print(newMessage);
      List<String> ids = [senderId, recieverId];
      ids.sort();
      String chatroom = ids.join('_');

      await _firestoreServices.sendMessage(newMessage, chatroom);
    }
    }catch(e){
      print(e);
    }
  }


}