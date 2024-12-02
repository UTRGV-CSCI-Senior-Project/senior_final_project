import 'package:flutter/material.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:google_fonts/google_fonts.dart';

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