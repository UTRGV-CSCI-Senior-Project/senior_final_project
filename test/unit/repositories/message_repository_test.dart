import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late MockFirestoreServices mockFirestoreServices;
  late MockAuthServices mockAuthServices;
  late MockCloudMessagingServices mockCloudMessagingServices;
  late ProviderContainer container;

  setUp(() {
    mockFirestoreServices = MockFirestoreServices();
    mockAuthServices = MockAuthServices();
    mockCloudMessagingServices = MockCloudMessagingServices();

    container = ProviderContainer(overrides: [
      authServicesProvider.overrideWithValue(mockAuthServices),
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
      cloudMessagingServicesProvider
          .overrideWithValue(mockCloudMessagingServices)
    ]);
  });

  group('sendMessage', () {
    const String senderId = 'user1';
    const String receiverId = 'user2';
    const String senderName = 'User One';
    const String message = 'Hello, World!';
    final List<String> participantTokens = ['token1', 'token2'];

    test('successfully sends message when sender ID is available', () async {
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => senderId);
      final messageRepository = container.read(messageRepositoryProvider);

      await messageRepository.sendMessage(
          senderName, receiverId, message, participantTokens);

      verify(mockAuthServices.currentUserUid()).called(1);

      verify(mockFirestoreServices.sendMessage(any, 'user1_user2')).called(1);

      verify(mockCloudMessagingServices.sendNotification(
              participantTokens, senderName, message))
          .called(1);
    });

    test('sends message without tokens when no participant tokens provided',
        () async {
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => senderId);
      final messageRepository = container.read(messageRepositoryProvider);

      await messageRepository.sendMessage(
          senderName, receiverId, message, null);

      verify(mockAuthServices.currentUserUid()).called(1);

      verify(mockFirestoreServices.sendMessage(any, 'user1_user2')).called(1);

      verifyNever(mockCloudMessagingServices.sendNotification(any, any, any));
    });

    test('throws AppException when currentUserUid returns null', () async {
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);
      final messageRepository = container.read(messageRepositoryProvider);

      expect(
          () => messageRepository.sendMessage(
              senderName, receiverId, message, participantTokens),
          throwsA(isA<AppException>()));
    });

    test('rethrows AppException from underlying services', () async {
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => senderId);
      when(mockFirestoreServices.sendMessage(any, any))
          .thenThrow(AppException('test-error'));
      final messageRepository = container.read(messageRepositoryProvider);

      expect(
          () => messageRepository.sendMessage(
              senderName, receiverId, message, participantTokens),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'error message', 'test-error')));
    });
  });

  group('getChatroomMessages', () {
    const String chatroomId = 'user1_user2';
    final List<MessageModel> mockMessages = [
      MessageModel(
          senderId: 'user1',
          recieverId: 'user2',
          message: 'Hello',
          timestamp: DateTime.now()),
      MessageModel(
          senderId: 'user2',
          recieverId: 'user1',
          message: 'Hi there',
          timestamp: DateTime.now())
    ];

    test('returns stream of messages for given chatroom', () {
      when(mockFirestoreServices.getChatroomMessages(chatroomId))
          .thenAnswer((_) => Stream.value(mockMessages));
      final messageRepository = container.read(messageRepositoryProvider);

      final messageStream = messageRepository.getChatroomMessages(chatroomId);

      expect(messageStream, emits(mockMessages));
      verify(mockFirestoreServices.getChatroomMessages(chatroomId)).called(1);
    });
  });
}
