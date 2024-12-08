import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/service_selection_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  File? file;
  final _fullNameController = TextEditingController();
  String errorMessage = "";
  bool _isLoading = false;
  bool _servicesAreLoading = true;
  final searchController = TextEditingController();
  List<String> filteredServices = [];
  late List<String> services = [];
      final nameFocusNode = FocusNode();
    final searchFocusNode = FocusNode();


  final Map<String, bool> selectedServices = {};

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    nameFocusNode.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredServices = services;
      });
      return;
    }
    setState(() {
      filteredServices = services
          .where(
              (service) => service.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> loadServices() async {
    try {
      final fetchedServices = await ref.read(servicesStreamProvider.future);
      if (mounted) {
        setState(() {
          services = fetchedServices;

          for (var service in services) {
            selectedServices[service] = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          services = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _servicesAreLoading = false;
        });
      }
    }
  }

  Future<void> onProfileTap() async {
    final ImagePicker imagePicker = ref.read(imagePickerProvider);
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (mounted) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  Widget buildProfile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Name and Profile Picture',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'This is how others will see you.',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: file != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: Image.file(
                              file!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 200,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.3),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      key: const Key('image-picker-button'),
                      onTap: onProfileTap,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.create_rounded,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onTap: () => nameFocusNode.requestFocus(),
              focusNode: nameFocusNode,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
              textCapitalization: TextCapitalization.words,
              key: const Key('name-field'),
              controller: _fullNameController,
              decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          if (errorMessage.isNotEmpty && _currentPage == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ErrorBox(
                  errorMessage: errorMessage,
                  onDismiss: () {
                    if (mounted) {
                      setState(() {
                        errorMessage = "";
                      });
                    }
                  }),
            ),
        ],
      ),
    );
  }

  Widget buildInterests(BuildContext context) {


    if (_servicesAreLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary),
      );
    }

    if (services.isEmpty) {
      return const ErrorView(
        bigText: 'Error fetching services!',
        smallText: 'Please check your connection, or try again later.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select the services you\'re interested in.',
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        Text(
          "Choose at least one!",
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(
            color: Colors.grey[500]!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            onTap: () => searchFocusNode.requestFocus(),
            cursorColor: Theme.of(context).textTheme.displayLarge?.color,
            controller: searchController,
            onChanged: filterServices,
            decoration: InputDecoration(
                hintText: 'Search Folio',
                enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(width: 2, color: Colors.grey[400]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide(width: 3, color: Colors.grey[400]!)),
                hintStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.displayLarge?.color),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).textTheme.displayLarge?.color),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                suffixIcon: searchController.text.isNotEmpty 
        ? IconButton(
          key: const Key('clear-search-button'),
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              filterServices('');
            },
          )
        : null,),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: ServiceSelectionWidget(
                services:
                    filteredServices.isNotEmpty ? filteredServices : services,
                initialSelectedServices: selectedServices,
                onServicesSelected: (newServices) {
                  if (mounted) {
                    setState(() {
                      errorMessage = "";
                      selectedServices.clear();
                      selectedServices.addAll(newServices);
                    });
                  }
                },
                isLoading: _isLoading)),
        if (errorMessage.isNotEmpty && _currentPage == 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ErrorBox(
                errorMessage: errorMessage,
                onDismiss: () {
                  if (mounted) {
                    setState(() {
                      errorMessage = "";
                    });
                  }
                }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 35,
        leading: _currentPage == 1
            ? IconButton(
                onPressed: () {
                  if (_currentPage == 1) {
                    _pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios),
              )
            : null,
        centerTitle: true,
        title: LinearProgressIndicator(
          minHeight: 6,
          borderRadius: BorderRadius.circular(5),
          value: (_currentPage + 1) / 2,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey[300],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int index) {
                    if (mounted) {
                      setState(() {
                        errorMessage = "";
                        _currentPage = index;
                      });
                    }
                  },
                  children: [buildProfile(context), buildInterests(context)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                    key: const Key('onboarding-button'),
                    onPressed: () async {
                      if (_currentPage == 0) {
                        if (_fullNameController.text.trim().isEmpty && _fullNameController.text.trim().length < 2) {
                          if (mounted) {
                            setState(() {
                              errorMessage = "Please enter your full name.";
                            });
                          }
                        } else {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      } else {
                        if (!selectedServices.values
                            .any((selected) => selected)) {
                          if (mounted) {
                            setState(() {
                              errorMessage = "Select at least one service.";
                            });
                          }
                          return;
                        } else {
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }
                          try {
                            final List<String> selectedServicesList =
                                selectedServices.entries
                                    .where((entry) => entry.value == true)
                                    .map((entry) => entry.key)
                                    .toList();
                            await ref
                                .read(userRepositoryProvider)
                                .updateProfile(profilePicture: file, fields: {
                              'fullName': _fullNameController.text,
                              'completedOnboarding': true,
                              'preferredServices': selectedServicesList
                            });

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen()));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              if (mounted) {
                                setState(() {
                                  errorMessage = e is AppException
                                      ? e.message
                                      : "Failed to update profile information. Please try again.";
                                  _isLoading =
                                      false; // Reset loading state on error
                                });
                              }
                            }
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: _isLoading ? Colors.grey[400] : const Color.fromARGB(255, 0, 111, 253),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 5,
                            ),
                          )
                        : Text(_currentPage == 0 ? 'Next' : 'Done!',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
