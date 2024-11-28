import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';

class ChatroomModel {
  final String id;
  final List<ChatParticipant> participants;
  final MessageModel lastMessage;
  final List<String> participantIds;

  ChatroomModel(
      {required this.id,
      required this.participants,
      required this.lastMessage,
      required this.participantIds}){
    if (id.isEmpty) {
      throw ArgumentError('id cannot be empty');
    }
    if (participants.isEmpty) {
      throw ArgumentError('participants cannot be empty');
    }
    if (participantIds.isEmpty) {
      throw ArgumentError('participantIds cannot be empty');
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage.toJson(),
      'participantIds': participantIds
    };
  }

  factory ChatroomModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      throw ArgumentError('empty-id');
    }
    if (!json.containsKey('participants')) {
      throw ArgumentError('empty-participants');
    }
    if (!json.containsKey('lastMessage')) {
      throw ArgumentError('empty-lastMessage');
    }
    if (!json.containsKey('participantIds')) {
      throw ArgumentError('empty-participantIds');
    }

    final participantsData = json['participants'] as List<dynamic>;
    final participants = participantsData
        .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
        .toList();

    final participantIds = (json['participantIds'] as List<dynamic>)
        .map((id) => id.toString())
        .toList();

    return ChatroomModel(
        id: json['id'] as String,
        participants: participants,
        lastMessage: MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
        participantIds: participantIds);
  }

  ChatParticipant otherParticipant (String currentUserId) {
    return participants.firstWhere(
      (p) => p.uid != currentUserId,
      orElse: () => participants.first,
    );
  }
}

