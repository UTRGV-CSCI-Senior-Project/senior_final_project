import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/home/chatroom_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxTab extends ConsumerStatefulWidget {
  final UserModel userModel;
  const InboxTab({super.key, required this.userModel});

  @override
  ConsumerState<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends ConsumerState<InboxTab> {
  @override
  Widget build(BuildContext context) {
    final chatroomstream = ref.watch(chatroomStreamProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chatroomstream.when(
              data: (chatrooms) {
                return Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...chatrooms.map(
                      (chatroom) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ChatRoomTile(
                          chatroom: chatroom,
                          currentUserId: widget.userModel.uid,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                return const Center(
                  child: ErrorView(
                    bigText: 'Error!',
                    smallText: 'There was an error loading your messages!',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final ChatroomModel chatroom;
  final String currentUserId;

  const ChatRoomTile({
    super.key,
    required this.chatroom,
    required this.currentUserId,
  });


  @override
  Widget build(BuildContext context) {

 final otherParticipant = chatroom.otherParticipant(currentUserId);
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatroomScreen(chatroomId: chatroom.id, otherParticipant: otherParticipant)));
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
