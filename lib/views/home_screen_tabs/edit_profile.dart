import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio_screen.dart';
import 'package:folio/views/state_screens.dart';
import 'package:folio/views/welcome_screen.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_share/social_share.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataStreamProvider);
    return userData.when(
      data: (userData) {
        if (userData != null) {
          final userModel = userData['user'];
          final userPortfolio = userData['portfolio'];

          void shareMessage() {
            String service = userPortfolio.service;
            String message =
                "Hello everyone! \nI invite you to check out my profile on the Folio App, \nwhere I showcase my $service services. You'll find a variety of photos \nthat highlight the quality of my work. The Folio App is available for download on both the App Store and Google Play Store.";
            SocialShare.shareOptions(message).then((result) {
              print(result);
            }).catchError((error) {
              print("Error sharing: $error");
            });
          }

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
                        child: userModel.profilePictureUrl != null
                            ? Image.network(
                                userModel.profilePictureUrl,
                                width: 125,
                                height: 125,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
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
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey)),
                              )
                            : Container(
                                width: 125,
                                height: 125,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image,
                                    size: 40, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userModel.fullName ?? userModel.username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (userPortfolio != null &&
                              userPortfolio.service != null)
                            Text(
                              userPortfolio.service!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          if (userPortfolio?.years != null &&
                              userPortfolio?.months != null)
                            if (userPortfolio.years == 0 &&
                                userPortfolio.months != 0)
                              Text("${userPortfolio.months} months")
                            else if (userPortfolio.years == 0 &&
                                userPortfolio.months == 0)
                              const SizedBox.shrink()
                            else if (userPortfolio.years != 0 &&
                                userPortfolio.months != 0)
                              Text(
                                  "${userPortfolio.years} yrs ${userPortfolio.months} months")
                            else if (userPortfolio.years != 0 &&
                                userPortfolio.months == 0)
                              Text("${userPortfolio.years} yrs"),
                          Text(
                            userModel.email,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (userPortfolio?.years != null &&
                              userPortfolio?.months != null)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: shareMessage,
                                  child: const Icon(
                                    Icons.facebook,
                                    color: Colors.blue,
                                    size: 35.0,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: shareMessage,
                                  child: const Icon(
                                    FontAwesomeIcons.twitter,
                                    color: Colors.black,
                                    size: 35.0,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                GestureDetector(
                                  onTap: shareMessage,
                                  child: const Icon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.green,
                                    size: 35.0,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40.0),
                if (userPortfolio != null)
                  Expanded(
                    child: Column(
                      children: [
                        Row(children: [
                          Text(
                            '${userPortfolio.service} Portfolio',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ]),
                        const SizedBox(
                          height: 16,
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8.0,
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio: 1),
                            itemCount: userPortfolio.images.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return GestureDetector(
                                  onTap: () async {
                                    final imagePicker =
                                        ref.watch(imagePickerProvider);
                                    final List<XFile> images =
                                        await imagePicker.pickMultiImage();

                                    if (images.isNotEmpty) {
                                      final List<File> selectedImages = [];
                                      for (var image in images) {
                                        selectedImages.add(File(image.path));
                                      }
                                      try {
                                        final portfolioRepository = ref
                                            .watch(portfolioRepositoryProvider);
                                        await portfolioRepository
                                            .updatePortfolio(
                                                images: selectedImages);
                                      } catch (e) {
                                        if (e is AppException) {
                                          setState(() {
                                            errorMessage = e.message;
                                          });
                                        } else {
                                          setState(() {
                                            errorMessage =
                                                "Changes to your portfolio could not be saved. Please try again.";
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue.withOpacity(0.1),
                                          width: 0),
                                      color: Colors.blue.withOpacity(0.1),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add_rounded,
                                          color: Color.fromRGBO(0, 111, 253, 1),
                                          size: 50),
                                    ),
                                  ),
                                );
                              } else {
                                final imageIndex = userPortfolio.images.length -
                                    (index - 1) -
                                    1;

                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        child: Image.network(
                                          userPortfolio.images[imageIndex]
                                              ['downloadUrl'],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey)),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          try {
                                            await ref
                                                .read(
                                                    portfolioRepositoryProvider)
                                                .deletePortfolioImage(
                                                    userPortfolio
                                                            .images[imageIndex]
                                                        ['filePath'],
                                                    userPortfolio
                                                            .images[imageIndex]
                                                        ['downloadUrl']);
                                          } catch (e) {
                                            if (e is AppException) {
                                              setState(() {
                                                errorMessage = e.message;
                                              });
                                            } else {
                                              setState(() {
                                                errorMessage =
                                                    "Failed to remove portfolio image. Please try again later.";
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                if (userPortfolio == null) const Spacer(),
                if (userPortfolio == null)
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                        key: const Key('create-portfolio-button'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreatePortfolioScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                          alignment: Alignment.center,
                        ),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.create_new_folder_outlined,
                                  size: 30),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'Become a Professional',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          );
                        })),
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
        } else {
          return const WelcomeScreen();
        }
      },
      loading: () => const LoadingView(),
      error: (error, stack) => const ErrorView(
        bigText: 'Something went wrong!',
        smallText: 'Try restarting the app',
      ),
    );
  }
}
