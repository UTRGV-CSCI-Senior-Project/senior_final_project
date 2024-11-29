import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends ConsumerStatefulWidget {
  final UserModel? userModel;
  final PortfolioModel? portfolioModel;

  const EditProfile(
      {super.key, required this.userModel, required this.portfolioModel});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  String errorMessage = "";
  bool _isImagePickerActive = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.userModel;
    final portfolio = widget.portfolioModel;
    return Scaffold(
      body: Padding(
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
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
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
                Column(
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
                    const SizedBox(height: 10),
                  ],
                )
              ],
            ),
            const SizedBox(height: 15.0),
            if (portfolio != null)
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      key: Key('tab-bar-key'),
                      tabs: [
                        Tab(text: 'Portfolio'),
                        Tab(text: 'More Details'),
                      ],
                    ),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [
                          ListView(children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 1,
                              ),
                              itemCount: portfolio.images.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (_isImagePickerActive) {
                                        return;
                                      }
                                      setState(() {
                                        _isImagePickerActive = true;
                                      });

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
                                          final portfolioRepository = ref.watch(
                                              portfolioRepositoryProvider);
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

                                      setState(() {
                                        _isImagePickerActive = false;
                                      });
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.3),
                                            width: 0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.add_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: 50),
                                      ),
                                    ),
                                  );
                                } else {
                                  final imageIndex =
                                      portfolio.images.length - (index - 1) - 1;

                                  return GestureDetector(
                                    onTap: () {
                                      _showEnlargedImageDialog(
                                          context,
                                          portfolio.images[imageIndex]
                                              ['downloadUrl']!);
                                    },
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            child: Image.network(
                                              portfolio.images[imageIndex]
                                                  ['downloadUrl']!,
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
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors
                                                              .grey[800])),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                            onPressed: () async {
                                              try {
                                                await ref
                                                    .read(
                                                        portfolioRepositoryProvider)
                                                    .deletePortfolioImage(
                                                        portfolio.images[
                                                                imageIndex]
                                                            ['filePath']!,
                                                        portfolio.images[
                                                                imageIndex]
                                                            ['downloadUrl']!);
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
                                    ),
                                  );
                                }
                              },
                            ),
                          ]),
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "${rightText(portfolio.years, portfolio.months)}\n${portfolio.details}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ErrorBox(
              errorMessage: errorMessage,
              onDismiss: () {
                setState(() {
                  errorMessage = "";
                });
              },
            )
          ],
        ),
      ),
    );
  }

  void _showEnlargedImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[800]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String rightText(int yrs, int months) {
  String service = '';
  if (yrs == 0) {
    if (months == 0) {
      service = '';
    } else if (months == 1) {
      service = '$months Month';
    } else {
      service = '$months Months';
    }
  } else if (yrs == 1) {
    service = '$yrs Year';
    if (months == 1) {
      service = '$service, $months Month';
    } else if (months > 1) {
      service = '$service, $months Months';
    }
  } else {
    service = '$yrs Years';
    if (months == 1) {
      service = '$service, $months Month';
    } else if (months > 1) {
      service = '$service, $months Months';
    }
  }

  return service;
}
