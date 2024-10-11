import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/views/home_screen.dart';
import 'package:folio/widgets/snackbar_widget.dart';
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
      print('error-loading');
    }
  }

  Future<void> onProfileTap() async {
    final ImagePicker imagePicker = ImagePicker();
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
                    height: 160,
                    width: 160,
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
                            size: 160,
                            color: Color.fromARGB(255, 180, 219, 255),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
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
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [buildProfile(context), buildInterests(context)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                    onPressed: () async {
                      if (_currentPage == 0) {
                        if (_fullNameController.text.isEmpty || file == null) {
                          showCustomSnackBar(context, 'empty-fields');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      } else {
                        try {
                          final List<String> selectedServicesList =
                              selectedServices.entries
                                  .where((entry) => entry.value == true)
                                  .map((entry) => entry.key)
                                  .toList();
                          await ref.read(userRepositoryProvider).updateProfile(profilePicture: file, fields: {
                            'fullName': _fullNameController.text,
                            'completedOnboarding': true,
                            'preferredServices': selectedServicesList});

                        } catch (e) {
                          print(e);
                        }
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      }
                    },
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: const Color.fromARGB(255, 0, 111, 253),
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(_currentPage == 0 ? 'Next' : 'Done!',
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













// // if(_fullNameController.text.isEmpty || file == null){
// //               showCustomSnackBar(context, 'empty-fields');
// //             }else{
// //               try{
// //                 ref.read(userRepositoryProvider).updateProfile(profilePicture: file, fields: {'fullName': _fullNameController.text});
// //               }catch(e){
// //                 print(e);
// //               }
// //                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
// //             }
// // 

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';

// class OnboardingScreen extends ConsumerStatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   File? file;
//   final _fullNameController = TextEditingController();

//   Future<void> onProfileTap() async {
//     final ImagePicker imagePicker = ImagePicker();
//     final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//     setState(() {
//       file = File(image.path);
//     });
//   }

//   Widget buildProfile(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: constraints.maxHeight),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Header Section
//                   Column(
//                     children: [
//                       const Text(
//                         'Name and Profile Picture',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           height: 1.2,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'This is how others will see you.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Profile Picture Section
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Center(
//                       child: Stack(
//                         children: [
//                           Container(
//                             height: 180,
//                             width: 180,
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 234, 242, 255),
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: file != null
//                                 ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(90),
//                                     child: Image.file(
//                                       file!,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons.person,
//                                     size: 100,
//                                     color: Color.fromARGB(255, 180, 219, 255),
//                                   ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: onProfileTap,
//                               child: Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: BoxDecoration(
//                                   color: const Color.fromARGB(255, 0, 111, 253),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 3,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.camera_alt,
//                                   size: 25,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//           controller: _fullNameController,
//           cursorColor: const Color.fromARGB(255, 0, 111, 253),
//           decoration: const InputDecoration(
//             hintText: 'Full Name',
//             focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//                 borderSide: BorderSide(
//                     color: Color.fromARGB(255, 0, 111, 253), width: 2.3)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//                 borderSide: BorderSide(
//                     color: Color.fromARGB(255, 104, 97, 97), width: 2)),
//           ),
//                     )],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Progress Indicator
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Step 1 of 3',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: const LinearProgressIndicator(
//                       value: .33,
//                       minHeight: 6,
//                       backgroundColor: Color.fromARGB(255, 234, 242, 255),
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Color.fromARGB(255, 0, 111, 253),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 children: [
//                   buildProfile(context),
//                 ],
//               ),
//             ),

//             // Bottom Button
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: ElevatedButton(
//                 onPressed: () async {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 0, 111, 253),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Continue',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Icon(Icons.arrow_forward),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }