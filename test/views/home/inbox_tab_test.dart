import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/repositories/message_repository.dart';
import 'package:folio/views/home/chatroom_screen.dart';
import 'package:folio/views/home/inbox_tab.dart';
import 'package:folio/widgets/chatroom_tile_widget.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/inbox_tab_test.mocks.dart';

@GenerateMocks([MessageRepository])
void main() {
  late UserModel testUser;
  late List<ChatroomModel> testChatrooms;
  late MockMessageRepository mockMessageRepository;

  setUp(() {
    mockMessageRepository = MockMessageRepository();
    // Sample user
    testUser = UserModel(
        uid: 'user1',
        username: 'username',
        email: 'email@email.com',
        isProfessional: false,
        fullName: 'Test User',
        completedOnboarding: true,
        isEmailVerified: true,
        profilePictureUrl: 'url');
    testChatrooms = [
      ChatroomModel(
          id: 'user1_user2',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'User One'),
            ChatParticipant(uid: 'user2', identifier: 'User Two')
          ],
          lastMessage: MessageModel(
              senderId: 'user1',
              recieverId: 'user2',
              message: 'Hello',
              timestamp: DateTime.now()),
          participantIds: ['user1', 'user2']),
      ChatroomModel(
          id: 'user1_user3',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'User One'),
            ChatParticipant(uid: 'user3', identifier: 'User Three')
          ],
          lastMessage: MessageModel(
              senderId: 'user3',
              recieverId: 'user1',
              message: 'Whats up',
              timestamp: DateTime.now()),
          participantIds: ['user2', 'user3']),
    ];
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        chatroomStreamProvider
            .overrideWith((ref) => Stream.value(testChatrooms)),
        messageRepositoryProvider.overrideWithValue(mockMessageRepository)
      ],
      child: MaterialApp(
        home: Scaffold(
          body: InboxTab(
            userModel: testUser,
          ),
        ),
      ),
    );
  }

  group('Inbox tab tests', () {
    testWidgets('shows loading indicator while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatroomStreamProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: MaterialApp(
            home: InboxTab(userModel: testUser),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when there are no chatrooms',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatroomStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: InboxTab(userModel: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(ChatRoomTile), findsNothing);
    });

    testWidgets('shows error message when there is an error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatroomStreamProvider
                .overrideWith((ref) => Stream.error('Test error')),
          ],
          child: MaterialApp(
            home: InboxTab(userModel: testUser),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error!'), findsOneWidget);
      expect(find.text('There was an error loading your messages!'),
          findsOneWidget);
    });

    testWidgets('displays chatroom tiles when there are chatrooms',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ChatRoomTile), findsExactly(2));
      expect(find.text('User Two'), findsOneWidget);
      expect(find.text('User Three'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Whats up'), findsOneWidget);
    });

    testWidgets('navigates to ChatroomScreen on tile tap', (tester) async {
      when(mockMessageRepository.getChatroomMessages(any))
          .thenAnswer((_) => Stream.value([
        MessageModel(
            senderId: 'user1',
            recieverId: 'user2',
            message: 'Hello',
            timestamp: DateTime.now()),
        MessageModel(
            senderId: 'user2',
            recieverId: 'user1',
            message: 'Hello there',
            timestamp: DateTime.now()),
      ]));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      // Tap the first chatroom tile
      await tester.tap(find.byType(ChatRoomTile).first);
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.byType(ChatroomScreen), findsOneWidget);
      expect(find.text('User Two'), findsOneWidget);
      expect(find.text('Hello'),
          findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget);
    });
  });
}
