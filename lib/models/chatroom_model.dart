import 'package:folio/models/message_model.dart';
import 'package:folio/models/user_model.dart';

class ChatroomModel {
  final String _id;
  final List<String> _participants;
  final List<MessageModel> _messages;
  final MessageModel _lastMessage;

  ChatroomModel({
    required String id,
    required List<String> participants,
    required List<MessageModel> messages,
    required MessageModel lastMessage
  }) :
  _id = id,
  _participants = participants,
  _messages = messages,
  _lastMessage = lastMessage {
     if(id.isEmpty){
      throw ArgumentError('id cannot be empty');
    }
    if(participants.isEmpty){
      throw ArgumentError('recieverId cannot be empty');
    }
    if(messages.isEmpty){
      throw ArgumentError('message cannot be empty');
    }
  }

  String get id => _id;
  List<String> get participants => _participants;
  List<MessageModel> get messsages => _messages;
  MessageModel get lastMessage => _lastMessage;

  Map<String, dynamic> toJson(){
    return {
      'id': _id,
      'participants': _participants,
      'messages': _messages,
      'lastMessage': _lastMessage
    };
  }

  factory ChatroomModel.fromJson(Map<String, dynamic> json){
    if (!json.containsKey('id')) {
      throw ArgumentError('empty-id');
    }
    if (!json.containsKey('participants')) {
      throw ArgumentError('empty-participants');
    }

    return ChatroomModel(id: json['id'] as String, participants: json['participants'] as List<String>, messages: json['messages'] as List<MessageModel>, lastMessage: json['lastMessage'] as MessageModel);
  }
}