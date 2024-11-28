import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folio/models/messaging_models/message_model.dart';

void main() {
  group('MessageModel', () {
    final testTimestamp = DateTime.now();

    test('constructor with valid data', () {
      final message = MessageModel(
        senderId: '123',
        recieverId: '456',
        message: 'Hello',
        timestamp: testTimestamp
      );

      expect(message.senderId, '123');
      expect(message.recieverId, '456');
      expect(message.message, 'Hello');
      expect(message.timestamp, testTimestamp);
    });

    test('constructor throws error for empty senderId', () {
      expect(
        () => MessageModel(
          senderId: '', 
          recieverId: '456', 
          message: 'Hello', 
          timestamp: testTimestamp
        ),
        throwsArgumentError
      );
    });

    test('constructor throws error for empty receiverId', () {
      expect(
        () => MessageModel(
          senderId: '123', 
          recieverId: '', 
          message: 'Hello', 
          timestamp: testTimestamp
        ),
        throwsArgumentError
      );
    });

    test('constructor throws error for empty message', () {
      expect(
        () => MessageModel(
          senderId: '123', 
          recieverId: '456', 
          message: '', 
          timestamp: testTimestamp
        ),
        throwsArgumentError
      );
    });

    test('toJson converts to correct map', () {
      final message = MessageModel(
        senderId: '123',
        recieverId: '456',
        message: 'Hello',
        timestamp: testTimestamp
      );

      final json = message.toJson();
      expect(json['senderId'], '123');
      expect(json['recieverId'], '456');
      expect(json['message'], 'Hello');
      expect(json['timestamp'], isA<Timestamp>());
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'senderId': '123',
        'recieverId': '456',
        'message': 'Hello',
        'timestamp': Timestamp.fromDate(testTimestamp)
      };

      final message = MessageModel.fromJson(json);
      expect(message.senderId, '123');
      expect(message.recieverId, '456');
      expect(message.message, 'Hello');
      expect(message.timestamp, testTimestamp);
    });

    test('fromJson throws error for missing senderId', () {
      final json = {
        'recieverId': '456',
        'message': 'Hello',
        'timestamp': Timestamp.fromDate(testTimestamp)
      };

      expect(
        () => MessageModel.fromJson(json),
        throwsArgumentError
      );
    });

    test('fromJson throws error for missing receiverId', () {
      final json = {
        'senderId': '123',
        'message': 'Hello',
        'timestamp': Timestamp.fromDate(testTimestamp)
      };

      expect(
        () => MessageModel.fromJson(json),
        throwsArgumentError
      );
    });

    test('fromJson throws error for missing message', () {
      final json = {
        'senderId': '123',
        'recieverId': '456',
        'timestamp': Timestamp.fromDate(testTimestamp)
      };

      expect(
        () => MessageModel.fromJson(json),
        throwsArgumentError
      );
    });

    test('fromJson throws error for missing timestamp', () {
      final json = {
        'senderId': '123',
        'recieverId': '456',
        'message': 'Hello'
      };

      expect(
        () => MessageModel.fromJson(json),
        throwsArgumentError
      );
    });
  });
}