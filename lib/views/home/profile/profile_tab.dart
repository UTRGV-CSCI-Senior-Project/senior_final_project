import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/home/profile/profile_portfolio_tab.dart';
import 'package:folio/views/home/profile/profile_schedule_tab.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePortfolio extends ConsumerStatefulWidget {
  final UserModel? userModel;
  final PortfolioModel? portfolioModel;

  const ProfilePortfolio(
      {super.key, required this.userModel, required this.portfolioModel});

  @override
  ConsumerState<ProfilePortfolio> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<ProfilePortfolio> {
  String errorMessage = "";
  PageController selectedIndex = PageController();
  int _curr = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex.addListener(() {
      setState(() {
        _curr = selectedIndex.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userModel;
    final portfolio = widget.portfolioModel;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(62),
                  child: (user!.profilePictureUrl != null &&
                          user.profilePictureUrl!.isNotEmpty)
                      ? Image.network(
                          user.profilePictureUrl!,
                          width: 95,
                          height: 95,
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
                        portfolio.service,
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                    // const Row(
                    //   children: [
                    //     Icon(
                    //       Icons.facebook,
                    //       color: Colors.blue,
                    //       size: 35.0,
                    //     ),
                    //     SizedBox(
                    //       width: 5.0,
                    //     ),
                    //     Icon(
                    //       Icons.tiktok,
                    //       color: Colors.black,
                    //       size: 35.0,
                    //     ),
                    //     SizedBox(
                    //       width: 5.0,
                    //     ),
                    //     Icon(
                    //       Icons.message,
                    //       color: Colors.green,
                    //       size: 35.0,
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () => selectedIndex.jumpToPage(0),
                child: const Text('Edit Profile'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => selectedIndex.jumpToPage(1),
                child: const Text('Portfolio Calendar'),
              ),
              const Spacer(),
            ],
          ),
          Expanded(
            child: PageView(
              controller: selectedIndex,
              onPageChanged: (index) {
                setState(() {
                  _curr = index;
                });
              },
              children: [
                EditProfile(userModel: user, portfolioModel: portfolio),
                PortfolioCalender(userModel: user, portfolioModel: portfolio),
              ],
            ),
          ),
          ErrorBox(
              errorMessage: errorMessage,
              onDismiss: () {
                setState(() {
                  errorMessage = "";
                });
              })
        ],
      ),
    );
  }
}
