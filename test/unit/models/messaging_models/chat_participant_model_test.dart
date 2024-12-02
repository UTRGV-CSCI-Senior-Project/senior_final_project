import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/user_model.dart';


void main() {
  group('ChatParticipant', () {
    test('constructor with valid data', () {
      final participant = ChatParticipant(
        uid: '123',
        identifier: 'John Doe',
        profilePicture: 'https://example.com/profile.jpg',
        fcmTokens: ['token1', 'token2']
      );

      expect(participant.uid, '123');
      expect(participant.identifier, 'John Doe');
      expect(participant.profilePicture, 'https://example.com/profile.jpg');
      expect(participant.fcmTokens, ['token1', 'token2']);
    });

    test('constructor throws error for empty uid', () {
      expect(
        () => ChatParticipant(uid: '', identifier: 'John Doe'),
        throwsArgumentError
      );
    });

    test('constructor throws error for empty identifier', () {
      expect(
        () => ChatParticipant(uid: '123', identifier: ''),
        throwsArgumentError
      );
    });

    test('toJson converts to correct map', () {
      final participant = ChatParticipant(
        uid: '123',
        identifier: 'John Doe',
        profilePicture: 'https://example.com/profile.jpg',
        fcmTokens: ['token1', 'token2']
      );

      final json = participant.toJson();
      expect(json['uid'], '123');
      expect(json['identifier'], 'John Doe');
      expect(json['profilePicture'], 'https://example.com/profile.jpg');
      expect(json['fcmTokens'], ['token1', 'token2']);
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'uid': '123',
        'identifier': 'John Doe',
        'profilePicture': 'https://example.com/profile.jpg',
        'fcmTokens': ['token1', 'token2']
      };

      final participant = ChatParticipant.fromJson(json);
      expect(participant.uid, '123');
      expect(participant.identifier, 'John Doe');
      expect(participant.profilePicture, 'https://example.com/profile.jpg');
      expect(participant.fcmTokens, ['token1', 'token2']);
    });

    test('fromUserModel creates instance from UserModel', () {
      final userModel = UserModel(
        uid: '123',
        email: 'email@email.com',
        isProfessional: false,
        username: 'johndoe',
        fullName: 'John Doe',
        profilePictureUrl: 'https://example.com/profile.jpg',
        fcmTokens: ['token1', 'token2']
      );

      final participant = ChatParticipant.fromUserModel(userModel);
      expect(participant.uid, '123');
      expect(participant.identifier, 'John Doe');
      expect(participant.profilePicture, 'https://example.com/profile.jpg');
      expect(participant.fcmTokens, ['token1', 'token2']);
    });

    test('fromUserModel uses username when fullName is null', () {
      final userModel = UserModel(
        uid: '123',
        email: 'email@email.com',
        isProfessional: false,
        username: 'johndoe',
        profilePictureUrl: 'https://example.com/profile.jpg',
        fcmTokens: ['token1', 'token2']
      );

      final participant = ChatParticipant.fromUserModel(userModel);
      expect(participant.uid, '123');
      expect(participant.identifier, 'johndoe');
      expect(participant.profilePicture, 'https://example.com/profile.jpg');
      expect(participant.fcmTokens, ['token1', 'token2']);
    });
  });
}