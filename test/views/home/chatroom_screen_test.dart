import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/views/home/chatroom_screen.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/inbox_tab_test.mocks.dart';

void main(){
  late MockMessageRepository mockMessageRepository;
  late String chatroomId;
  late ChatParticipant otherParticipant;
  late String senderName;
 
  setUp((){
    mockMessageRepository = MockMessageRepository();
    chatroomId = 'user1_user2';
    otherParticipant = ChatParticipant(uid: 'user2', identifier: 'User Two', fcmTokens: []);
    senderName = 'User One';

  });

  Widget createTestWidget(){
    return ProviderScope(
      overrides: [
        messageRepositoryProvider.overrideWithValue(mockMessageRepository)
      ],
      child: MaterialApp(
      home: ChatroomScreen(chatroomId: chatroomId, otherParticipant: otherParticipant, senderName: senderName),
    ));
  }

  group('Chatroom Screen Tests', () {
    testWidgets("displays other user's name and the messages correctly", (WidgetTester tester) async {
       // Arrange
        when(mockMessageRepository.getChatroomMessages('user1_user2'))
            .thenAnswer((_) => Stream.value([
                  MessageModel(
            senderId: 'user1',
            recieverId: 'user2',
            message: 'Hello',
            timestamp: DateTime.now()),
        MessageModel(
            senderId: 'user2',
            recieverId: 'user1',
            message: 'Howdy',
            timestamp: DateTime.now()),
                ]));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('User Two'), findsOneWidget);
        expect(find.text('Hello'), findsOneWidget);
        expect(find.text('Howdy'), findsOneWidget);
    });

    testWidgets(
      'Send functionality works',
      (WidgetTester tester) async {
        // Arrange
        when(mockMessageRepository.getChatroomMessages('user1_user2'))
            .thenAnswer((_) => Stream.value([
                  MessageModel(
            senderId: 'user1',
            recieverId: 'user2',
            message: 'Hello',
            timestamp: DateTime.now()),
        MessageModel(
            senderId: 'user2',
            recieverId: 'user1',
            message: 'Howdy',
            timestamp: DateTime.now()),
                ]));
        when(mockMessageRepository.sendMessage(
          'User One',
          'user2',
          'Hello again',
          []
        )).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Act
        await tester.enterText(find.byType(TextField), 'Hello again');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        // Assert
        verify(mockMessageRepository.sendMessage(
          'User One',
          'user2',
          'Hello again',
          []
        )).called(1);
      },
    );
  });
}