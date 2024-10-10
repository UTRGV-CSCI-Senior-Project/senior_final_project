import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folio/views/home_screen.dart';
import 'package:folio/services/edit_profile_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? imageUrl;
  String? fullName;
  String? serviceType;
  String? email;
  List<String> userImages = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
    _fetchFullName();
    _fetchServiceType();
    _fetchEmail();
    _fetchUserFolio();
  }

  Future<void> _fetchUserFolio() async {
    List<String> images = await fetchUserFolio();
    setState(() {
      userImages = images;
    });
  }

  Future<void> _fetchProfileImage() async {
    String? url = await getProfileImageUrl();
    setState(() {
      imageUrl = url;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await uploadProfileImage(pickedFile.path);
      _fetchProfileImage();
      _fetchFullName();
      _fetchServiceType();
      _fetchEmail();
    }
  }

  Future<void> _fetchFullName() async {
    String? name = await getFullName();
    setState(() {
      fullName = name;
    });
  }

  Future<void> _fetchServiceType() async {
    String? service = await getServiceType();
    setState(() {
      serviceType = service;
    });
  }

  Future<void> _fetchEmail() async {
    String uid = await FirebaseAuth.instance.currentUser!.uid;
    String? fetchedEmail = await getEmail(uid);
    setState(() {
      email = fetchedEmail;
    });
  }

  Future<void> _uploadImageFolio() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? downloadUrl =
          await uploadImage(imageFile); // Call the upload function

      if (downloadUrl != null) {
        setState(() {
          userImages.add(downloadUrl); // Update the list of images
        });
        print("Image uploaded successfully! URL: $downloadUrl");

        // You can update the UI or Firestore with the new image URL if needed
      } else {
        print("Failed to upload image.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: imageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName ?? 'No Name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceType ?? 'No Service',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email != null ? '$email' : 'No email',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.facebook,
                          color: Colors.blue,
                          size: 35.0,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Icon(
                          Icons.tiktok,
                          color: Colors.black,
                          size: 35.0,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Icon(
                          Icons.message,
                          color: Colors.green,
                          size: 35.0,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            Row(children: [
              const Text(
                'Portfolio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _uploadImageFolio,
                child: const Text(
                  'Upload Pictures',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
            ]),
            Expanded(
              child: userImages.isEmpty
                  ? const Center(child: Text('No images uploaded.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 2.0,
                      ),
                      itemCount: userImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: 100, // Set the desired width
                              height: 100, // Set the desired height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    8), // Optional: Rounded corners
                                image: DecorationImage(
                                  image: NetworkImage(userImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool success =
                                    await deleteImageFolio(userImages[index]);
                                if (success) {
                                  setState(() {
                                    userImages.removeAt(index);
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
