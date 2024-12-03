import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/widgets/message_tile_widget.dart';

class ChatroomScreen extends ConsumerStatefulWidget {
  final String chatroomId;
  final ChatParticipant otherParticipant;
  final String senderName;
  const ChatroomScreen(
      {super.key,
      required this.chatroomId,
      required this.otherParticipant,
      required this.senderName});

  @override
  ConsumerState<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends ConsumerState<ChatroomScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherParticipant.identifier),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: ref
                    .watch(messageRepositoryProvider)
                    .getChatroomMessages(widget.chatroomId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageTile(
                        message: messages[index],
                        otherUserId: widget.otherParticipant.uid,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('message-field'),
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 2, color: Colors.grey[400]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            borderSide:
                                BorderSide(width: 3, color: Colors.grey[400]!)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  ElevatedButton(
                    key: const Key('send-message-button'),
                    onPressed: () async {
                      if (_messageController.text.isEmpty) {
                        return;
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await ref.read(messageRepositoryProvider).sendMessage(
                              widget.senderName,
                              widget.otherParticipant.uid,
                              _messageController.text,
                              widget.otherParticipant.fcmTokens);
                          _messageController.clear();
                        } catch (e) {
                          //Catch Error
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.7),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
