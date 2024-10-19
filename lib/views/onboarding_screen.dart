import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/constants/error_constants.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/home_screen.dart';
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

  late List<String> services = [];

  final Map<String, bool> selectedServices = {};

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final firestoreServices = ref.read(firestoreServicesProvider);
      final fetchedServices = await firestoreServices.getServices();
      setState(() {
        services = fetchedServices;

        for (var service in services) {
          selectedServices[service] = false;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> onProfileTap() async {
    final ImagePicker imagePicker = ref.read(imagePickerProvider);
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      file = File(image.path);
    });
  }

  Widget buildProfile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Name and Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'This is how others will see you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 234, 242, 255),
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
                        : const Icon(
                            Icons.person,
                            size: 200,
                            color: Color.fromARGB(255, 180, 219, 255),
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
                          color: const Color.fromARGB(255, 0, 111, 253),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.create_rounded,
                          size: 30,
                          color: Colors.white,
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
              key: const Key('name-field'),
              controller: _fullNameController,
              cursorColor: const Color.fromARGB(255, 0, 111, 253),
              decoration: const InputDecoration(
                hintText: 'Full Name',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 111, 253), width: 2.3)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 104, 97, 97), width: 2)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildInterests(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'What professions are you interested in?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            "Choose as many as you'd like",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 50),
          ...services.map((service) {
            bool isSelected = selectedServices[service] ?? false;
            return GestureDetector(
              key: Key('${service}-button'),
                onTap: () => setState(() {
                      selectedServices[service] = !isSelected;
                    }),
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(229, 255, 200, 100)
                          : Colors
                              .transparent, // Change background color when selected
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromRGBO(9, 195, 54, 100)
                            : Colors.grey,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            service,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Color.fromRGBO(9, 195, 19, 100),
                                  size: 20,
                                )
                              : Container(),
                        ],
                      ),
                    )));
          })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentPage + 1) / 2,
                color: Colors.blue,
                backgroundColor: const Color.fromARGB(255, 234, 242, 255),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                      errorMessage = "";
                    });
                  },
                  children: [buildProfile(context), buildInterests(context)],
                ),
              ),
              errorMessage.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            Colors.red.withOpacity(0.1), // Light red background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.error_outline,
                            color: Colors.red), // Error icon
                        title: Text(
                          errorMessage,
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              errorMessage = ""; // Dismiss error message
                            });
                          },
                        ),
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  key: const Key('onboarding-button'),
                    onPressed: () async {
                      if (_currentPage == 0) {
                        if (_fullNameController.text.isEmpty) {
                          setState(() {
                            errorMessage =
                                "Please enter your full name.";
                          });
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
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

                          if (mounted) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()));
                          }
                        } catch (e) {
                          setState(() {
                            errorMessage =
                                ErrorConstants.getMessage(e.toString());
                          });
                        } finally {
                          if (mounted) {
                            _isLoading = false;
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: const Color.fromARGB(255, 0, 111, 253),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                          )
                        : Text(_currentPage == 0 ? 'Next' : 'Done!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
