import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatroomScreen extends ConsumerStatefulWidget {
  final String chatroomId;
  final ChatParticipant otherParticipant;
  final String senderName;
  const ChatroomScreen(
      {super.key, required this.chatroomId, required this.otherParticipant, required this.senderName});

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
                    onPressed: () async {
                      if (_messageController.text.isEmpty) {
                        return;
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await ref.read(messageRepositoryProvider).sendMessage(widget.senderName,
                              widget.otherParticipant.uid,
                              _messageController.text, widget.otherParticipant.fcmTokens);
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
                      backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
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

class MessageTile extends StatelessWidget {
  final MessageModel message;
  final String otherUserId;

  const MessageTile({
    super.key,
    required this.message,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isSentByCurrentUser = message.senderId != otherUserId;

    return Align(
        alignment:
            isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isSentByCurrentUser ? Theme.of(context).colorScheme.tertiary.withOpacity(0.7) : Colors.grey[600],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24.0),
                topRight: const Radius.circular(24.0),
                bottomLeft: isSentByCurrentUser
                    ? const Radius.circular(24.0)
                    : Radius.zero,
                bottomRight: isSentByCurrentUser
                    ? Radius.zero
                    : const Radius.circular(24.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: isSentByCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  textAlign:
                      isSentByCurrentUser ? TextAlign.right : TextAlign.left,
                  message.message,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onTertiary,)
                ),
                const SizedBox(height: 4),
                Text(
                  textAlign:
                      isSentByCurrentUser ? TextAlign.right : TextAlign.left,
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  String _formatDate(DateTime timestamp) {
    return "${timestamp.month}/${timestamp.day}/${timestamp.year.toString().replaceRange(0, 2, '')} ${timestamp.hour > 12 ? timestamp.hour % 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
