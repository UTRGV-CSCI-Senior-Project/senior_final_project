import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/chatroom_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewProfileScreen extends ConsumerStatefulWidget {
  final UserModel currentUser;
  final String uid;
  final PortfolioModel? portfolioModel;
  const ViewProfileScreen(
      {super.key,
      required this.uid,
      this.portfolioModel,
      required this.currentUser});

  @override
  ConsumerState<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends ConsumerState<ViewProfileScreen> {
  late UserModel user;
  bool isLoading = true;
  bool isDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  String generateChatroomId(String currentUserId, String otherUserId) {
    List<String> sortedIds = [currentUserId, otherUserId]..sort();

    return sortedIds.join('_');
  }

  Future<void> _loadUser() async {
    final userModel =
        await ref.read(userRepositoryProvider).getOtherUser(widget.uid);
    if (userModel != null) {
      setState(() {
        user = userModel;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = widget.portfolioModel;
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(57),
                  child: (user.profilePictureUrl != null &&
                          user.profilePictureUrl!.isNotEmpty)
                      ? Image.network(
                          user.profilePictureUrl!,
                          width: 115,
                          height: 115,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 95,
                                  height: 95,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey[800])),
                        )
                      : Container(
                          width: 95,
                          height: 95,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 40, color: Colors.grey[800]),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? user.username,
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (portfolio != null)
                        Text(
                          '${portfolio.service} for ${portfolio.getFormattedTotalExperience()}',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      if (portfolio != null)
                        Text(
                            '${portfolio.location?['city']}, ${portfolio.location?['state']}',
                            style: GoogleFonts.inter(fontSize: 16))
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 40.0),
            if (portfolio != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (portfolio.details.isNotEmpty)
                        Text(
                          'Details',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.displayLarge?.color,
                          ),
                        ),
                      Text(
                        isDetailsExpanded
                            ? portfolio.details
                            : portfolio.details.length > 75
                                ? portfolio.details.substring(0, 75)
                                : portfolio.details,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color:
                              Theme.of(context).textTheme.displayLarge?.color,
                        ),
                      ),
                      if (portfolio.details.length > 75)
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isDetailsExpanded = !isDetailsExpanded;
                              });
                            },
                            child: Text(
                              isDetailsExpanded ? 'less' : 'more',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Text('Images',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 12,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 1),
                        itemCount: portfolio.images.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            child: Image.network(
                              portfolio.images[index]['downloadUrl']!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.broken_image,
                                          color: Colors.grey[800])),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      )),
      floatingActionButton: widget.currentUser.uid == user.uid
          ? null
          : FloatingActionButton(
              onPressed: () {
                String chatroomId =
                    generateChatroomId(widget.currentUser.uid, user.uid);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatroomScreen(
                            chatroomId: chatroomId,
                            otherParticipant:
                                ChatParticipant.fromUserModel(user),
                            senderName: widget.currentUser.fullName ??
                                widget.currentUser.username)));
              },
              backgroundColor: Colors.lightGreen,
              elevation: 2,
              child: const Icon(
                Icons.message,
                size: 30,
              ),
            ),
    );
  }
}
