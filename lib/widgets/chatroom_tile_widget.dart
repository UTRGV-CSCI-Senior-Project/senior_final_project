import 'package:flutter/material.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/chatroom_screen.dart';

class ChatRoomTile extends StatelessWidget {
  final ChatroomModel chatroom;
  final String currentUserId;
  final UserModel sender;

  const ChatRoomTile({
    super.key,
    required this.chatroom,
    required this.currentUserId,
    required this.sender
  });


  @override
  Widget build(BuildContext context) {

 final otherParticipant = chatroom.otherParticipant(currentUserId);
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatroomScreen(chatroomId: chatroom.id, otherParticipant: otherParticipant, sender: sender,)));
      },
      leading: CircleAvatar(
        radius: 28,
        child: otherParticipant.profilePicture != null
            ? ClipOval(
                child: Image.network(
                  otherParticipant.profilePicture ?? '',
                  fit: BoxFit.cover,
                  width: 56, // Adjust width to match CircleAvatar size
                  height: 56,
                   loadingBuilder: (context, child, loadingProgress) {
                            return const Icon(Icons.person, size: 28);
                           
                          },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 28); // Fallback icon
                  },
                ),
              )
            : const Icon(Icons.person, size: 28),
      ),
      title: Text(
        otherParticipant.identifier,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chatroom.lastMessage.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      trailing: Text(
        formatTimestamp(chatroom.lastMessage.timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inDays < 1) {
    return '${difference.inHours} hr ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} days ago';
  } else {
    return '${(difference.inDays / 30).floor()} months ago';
  }
}