import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio_tabs/choose_service_screen.dart';
import 'package:folio/views/create_portfolio_tabs/input_experience_screen.dart';
import 'package:folio/views/create_portfolio_tabs/more_details_screen.dart';
import 'package:folio/views/create_portfolio_tabs/upload_pictures_screen.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePortfolioScreen extends ConsumerStatefulWidget {
  const CreatePortfolioScreen({super.key});

  @override
  ConsumerState<CreatePortfolioScreen> createState() =>
      _CreatePortfolioScreenState();
}

class _CreatePortfolioScreenState extends ConsumerState<CreatePortfolioScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedService;
  int _years = 0;
  int _months = 0;
  List<File> _images = [];
  String? _details;
  String errorMessage = "";
  bool _isLoading = false;

  void _onServiceSelected(String service) {
    setState(() {
      errorMessage = "";
      _selectedService = service;
    });
  }

  void _onExperienceEntered(int years, int months) {
    setState(() {
      errorMessage = "";
      _years = years;
      _months = months;
    });
  }

  void _onImagesAdded(List<File> files) {
    setState(() {
      errorMessage = "";
      _images = files;
    });
  }

  void _onDetailsEntered(String details) {
    setState(() {
      errorMessage = "";
      _details = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                leading: IconButton(
            key: const Key('close-button'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.clear_rounded,
              size: 40,
            )),
        title: Padding(
          padding:
              const EdgeInsets.only(right: 16.0), // Add padding on the right
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 4,
color: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey[300],            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        titleSpacing: 0,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                ChooseService(onServiceSelected: _onServiceSelected),
                InputExperience(onExperienceEntered: _onExperienceEntered),
                UploadPictures(
                  onImagesAdded: _onImagesAdded,
                  selectedImages: _images,
                ),
                MoreDetailsScreen(onDetailsEntered: _onDetailsEntered),
              ],
            )),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 24), // Add padding above the error box
              child: Column(
                children: [
                  ErrorBox(
                      errorMessage: errorMessage,
                      onDismiss: () {
                        setState(() {
                          errorMessage = "";
                        });
                      }),
                  TextButton(
                      key: const Key('portfolio-next-button'),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                errorMessage = "";
                              });
                              if (_currentPage == 0) {
                                if (_selectedService == null ||
                                    _selectedService!.isEmpty) {
                                  setState(() {
                                    errorMessage = "Please select a service.";
                                  });
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              } else if (_currentPage == 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else if (_currentPage == 2) {
                                if (_images.isEmpty ||
                                    _images.length < 5) {
                                  errorMessage =
                                      "Please upload at least 5 images.";
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              } else if (_currentPage == 3) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final portfolioRepository =
                                    ref.watch(portfolioRepositoryProvider);

                                if (_selectedService == null ||
                                    _selectedService!.isEmpty) {
                                  setState(() {
                                    errorMessage = "Please select a service.";
                                    _isLoading = false;
                                  });
                                  _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  return;
                                }
                                try {
                                  await portfolioRepository.createPortfolio(
                                      _selectedService!,
                                      _details ?? '',
                                      _months,
                                      _years,
                                      _images);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (e is AppException) {
                                    setState(() {
                                      errorMessage = e.message;
                                    });
                                  } else {
                                    setState(() {
                                      errorMessage =
                                          "Failed to create your portfolio. Please try again.";
                                    });
                                  }
                                } finally {
                                  if (mounted) {
                                    _isLoading = false;
                                  }
                                }
                              }
                            },
                      style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                         ),
                      child: _isLoading
                          ?  SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 5,
                              ),
                            )
                          : Text(
                              _currentPage != 3 ? 'Next' : 'Done!',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
