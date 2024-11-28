import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/widgets/chatroom_tile_widget.dart';
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
                          senderName: widget.userModel.fullName ?? widget.userModel.username,
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
