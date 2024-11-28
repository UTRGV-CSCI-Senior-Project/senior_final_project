import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';

void main() {
  group('ChatroomModel', () {
    late ChatParticipant participant1;
    late ChatParticipant participant2;
    late MessageModel lastMessage;

    setUp(() {
      participant1 = ChatParticipant(
        uid: '123',
        identifier: 'User One'
      );
      participant2 = ChatParticipant(
        uid: '456',
        identifier: 'User Two'
      );
      lastMessage = MessageModel(
        senderId: '123',
        recieverId: '456',
        message: 'Hello',
        timestamp: DateTime.now()
      );
    });

    test('constructor with valid data', () {
      final chatroom = ChatroomModel(
        id: 'room1',
        participants: [participant1, participant2],
        lastMessage: lastMessage,
        participantIds: ['123', '456']
      );

      expect(chatroom.id, 'room1');
      expect(chatroom.participants, [participant1, participant2]);
      expect(chatroom.lastMessage, lastMessage);
      expect(chatroom.participantIds, ['123', '456']);
    });

    test('constructor throws error for empty id', () {
      expect(
        () => ChatroomModel(
          id: '', 
          participants: [participant1, participant2],
          lastMessage: lastMessage,
          participantIds: ['123', '456']
        ),
        throwsArgumentError
      );
    });

    test('constructor throws error for empty participants', () {
      expect(
        () => ChatroomModel(
          id: 'room1', 
          participants: [],
          lastMessage: lastMessage,
          participantIds: ['123', '456']
        ),
        throwsArgumentError
      );
    });

    test('constructor throws error for empty participantIds', () {
      expect(
        () => ChatroomModel(
          id: 'room1', 
          participants: [participant1, participant2],
          lastMessage: lastMessage,
          participantIds: []
        ),
        throwsArgumentError
      );
    });

    test('toJson converts to correct map', () {
      final chatroom = ChatroomModel(
        id: 'room1',
        participants: [participant1, participant2],
        lastMessage: lastMessage,
        participantIds: ['123', '456']
      );

      final json = chatroom.toJson();
      expect(json['id'], 'room1');
      expect(json['participants'], isNotEmpty);
      expect(json['lastMessage'], isNotNull);
      expect(json['participantIds'], ['123', '456']);
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'id': 'room1',
        'participants': [
          participant1.toJson(),
          participant2.toJson()
        ],
        'lastMessage': lastMessage.toJson(),
        'participantIds': ['123', '456']
      };

      final chatroom = ChatroomModel.fromJson(json);
      expect(chatroom.id, 'room1');
      expect(chatroom.participants.length, 2);
      expect(chatroom.lastMessage, isNotNull);
      expect(chatroom.participantIds, ['123', '456']);
    });

    test('fromJson throws error for missing id', () {
      final json = {
        'participants': [
          participant1.toJson(),
          participant2.toJson()
        ],
        'lastMessage': lastMessage.toJson(),
        'participantIds': ['123', '456']
      };

      expect(
        () => ChatroomModel.fromJson(json),
        throwsArgumentError
      );
    });

    test('otherParticipant returns correct participant', () {
      final chatroom = ChatroomModel(
        id: 'room1',
        participants: [participant1, participant2],
        lastMessage: lastMessage,
        participantIds: ['123', '456']
      );

      final otherParticipant1 = chatroom.otherParticipant('123');
      expect(otherParticipant1, participant2);

      final otherParticipant2 = chatroom.otherParticipant('456');
      expect(otherParticipant2, participant1);
    });

    test('otherParticipant returns first participant if no match', () {
      final chatroom = ChatroomModel(
        id: 'room1',
        participants: [participant1, participant2],
        lastMessage: lastMessage,
        participantIds: ['123', '456']
      );

      final otherParticipant = chatroom.otherParticipant('789');
      expect(otherParticipant, participant1);
    });
  });
}