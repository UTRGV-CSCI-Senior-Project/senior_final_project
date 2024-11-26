import 'package:flutter_test/flutter_test.dart';
import 'package:folio/models/feedback_model.dart';

void main() {
   group('FeedbackModel Tests', () {
    test('should create FeedbackModel instance with all required fields', () {
      final now = DateTime.now();
      final feedback = FeedbackModel(
        id: '123',
        subject: 'Test Subject',
        message: 'Test Message',
        type: 'bug',
        deviceInfo: 'Test Device',
        appVersion: '1.0.0',
        createdAt: now,
        userId: 'user123',
      );

      expect(feedback.id, '123');
      expect(feedback.subject, 'Test Subject');
      expect(feedback.message, 'Test Message');
      expect(feedback.type, 'bug');
      expect(feedback.deviceInfo, 'Test Device');
      expect(feedback.appVersion, '1.0.0');
      expect(feedback.createdAt, now);
      expect(feedback.userId, 'user123');
    });

    
    test('should throw ArgumentError when id is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '',
            subject: 'Test Subject',
            message: 'Test Message',
            type: 'bug',
            deviceInfo: 'Test Device',
            appVersion: '1.0.0',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when subject is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: '',
            message: 'Test Message',
            type: 'bug',
            deviceInfo: 'Test Device',
            appVersion: '1.0.0',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when message is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: 'Test Subject',
            message: '',
            type: 'bug',
            deviceInfo: 'Test Device',
            appVersion: '1.0.0',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when type is invalid', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: 'Test Subject',
            message: 'Test Message',
            type: 'invalid_type',
            deviceInfo: 'Test Device',
            appVersion: '1.0.0',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when deviceInfo is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: 'Test Subject',
            message: 'Test Message',
            type: 'bug',
            deviceInfo: '',
            appVersion: '1.0.0',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when appVersion is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: 'Test Subject',
            message: 'Test Message',
            type: 'bug',
            deviceInfo: 'Test Device',
            appVersion: '',
            createdAt: now,
            userId: 'user123',
          ), throwsArgumentError);
    });

    test('should throw ArgumentError when userId is empty', () {
      final now = DateTime.now();
      expect(() => FeedbackModel(
            id: '123',
            subject: 'Test Subject',
            message: 'Test Message',
            type: 'bug',
            deviceInfo: 'Test Device',
            appVersion: '1.0.0',
            createdAt: now,
            userId: '',
          ), throwsArgumentError);
    });

    test('should convert FeedbackModel to JSON correctly', () {
      final now = DateTime.now();
      final feedback = FeedbackModel(
        id: '123',
        subject: 'Test Subject',
        message: 'Test Message',
        type: 'bug',
        deviceInfo: 'Test Device',
        appVersion: '1.0.0',
        createdAt: now,
        userId: 'user123',
      );

      final json = feedback.toJson();

      expect(json['id'], '123');
      expect(json['subject'], 'Test Subject');
      expect(json['message'], 'Test Message');
      expect(json['type'], 'bug');
      expect(json['deviceInfo'], 'Test Device');
      expect(json['appVersion'], '1.0.0');
      expect(json['createdAt'], now);
      expect(json['userId'], 'user123');
    });
  });
}