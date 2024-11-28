import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String recieverId;
  final String message;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.recieverId,
    required this.message,
    required this.timestamp
  }){
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

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'recieverId': recieverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp)
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

    return MessageModel(senderId: json['senderId'] as String, recieverId: json['recieverId'] as String, message: json['message'] as String, timestamp: (json['timestamp'] as Timestamp).toDate());
  }
  
}