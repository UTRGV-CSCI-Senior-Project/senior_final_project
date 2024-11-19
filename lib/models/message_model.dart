import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String _senderId;
  final String _recieverId;
  final String _message;
  final Timestamp _timestamp;

  MessageModel({
    required String senderId,
    required String recieverId,
    required String message,
    required Timestamp timestamp
  }) :
  _senderId = senderId,
  _recieverId = recieverId,
  _message = message,
  _timestamp = timestamp {
    if(senderId.isEmpty){
      throw ArgumentError('senderId cannot be empty');
    }
    if(recieverId.isEmpty){
      throw ArgumentError('recieverId cannot be empty');
    }
    if(message.isEmpty){
      throw ArgumentError('message cannot be empty');
    }
  }

  String get senderId => _senderId;
  String get recieverId => _recieverId;
  String get message => _message;
  Timestamp get timestamp => _timestamp;

  Map<String, dynamic> toJson() {
    return {
      'senderId': _senderId,
      'recieverId': _recieverId,
      'message': _message,
      'timestamp': _timestamp
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json){
    if (!json.containsKey('senderId')) {
      throw ArgumentError('empty-senderId');
    }
    if (!json.containsKey('recieverId')) {
      throw ArgumentError('empty-recieverId');
    }
    if (!json.containsKey('message')) {
      throw ArgumentError('empty-message');
    }
    if (!json.containsKey('timestamp')) {
      throw ArgumentError('empty-timestamp');
    }

    return MessageModel(senderId: json['senderId'] as String, recieverId: json['recieverId'] as String, message: json['message'] as String, timestamp: json['timestamp'] as Timestamp);
  }
  
}