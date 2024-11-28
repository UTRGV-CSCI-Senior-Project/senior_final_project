import 'package:folio/core/app_exception.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/cloud_messaging_services.dart';
import 'package:folio/services/firestore_services.dart';

class MessageRepository {
  final FirestoreServices _firestoreServices;
  final AuthServices _authServices;
  final CloudMessagingServices _cloudMessagingServices;

  MessageRepository(this._firestoreServices, this._authServices,
      this._cloudMessagingServices);

  Future<void> sendMessage(String senderName, String recieverId, String message,
      List<String>? otherParticipantTokens) async {
    try {
      final senderId = await _authServices.currentUserUid();
      if (senderId != null) {
        final DateTime timestamp = DateTime.now();
        final newMessage = MessageModel(
            senderId: senderId,
            recieverId: recieverId,
            message: message,
            timestamp: timestamp);
        List<String> ids = [senderId, recieverId];
        ids.sort();
        String chatroom = ids.join('_');

        await _firestoreServices.sendMessage(newMessage, chatroom);

        if (otherParticipantTokens != null &&
            otherParticipantTokens.isNotEmpty) {
          await _cloudMessagingServices.sendNotification(
              otherParticipantTokens, senderName, message);
        }
      }else{
        throw AppException('no-user');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('send-message-error');
      }
    }
  }

  Stream<List<MessageModel>> getChatroomMessages(String chatroomId) {
    return _firestoreServices.getChatroomMessages(chatroomId);
  }
}
