import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<bool> isProfessionalStatus() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return false;
    }

    final userId = user.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot doc = await userRef.get();

    // Check if the document exists and retrieve the isProfessional value
    if (doc.exists) {
      // Access the data as a Map
      final data = doc.data() as Map<String, dynamic>?;
      bool isProfessional = data?['isProfessional'] ?? false;
      return isProfessional;
    } else {
      print("User document does not exist.");
      return false;
    }
  } catch (e) {
    print("Error fetching professional status: $e");
    return false;
  }
}

Future<String?> getProfileImageUrl() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return null;
    }

    final userId = user.uid;
    final imageRef =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId');

    // Get the download URL
    String url = await imageRef.getDownloadURL();
    return url;
  } catch (e) {
    print("Error fetching profile image: $e");
    return null;
  }
}

Future<void> uploadProfileImage(String filePath) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return;
    }

    final userId = user.uid;
    final ref =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId');

    await ref.putFile(File(filePath));
  } catch (e) {
    print("Error uploading image: $e");
  }
}

Future<void> deleteProfileImage() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return;
    }

    final userId = user.uid;
    final ref =
        FirebaseStorage.instance.ref().child('profile_pictures/$userId');

    await ref.delete();
  } catch (e) {
    print("Error deleting image: $e");
  }
}

Future<String?> getFullName() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return null;
    }

    final userId = user.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      String fullName = data?['fullName'] ?? 'No Name';
      return fullName;
    } else {
      print("User document does not exist.");
      return 'No Name';
    }
  } catch (e) {
    print("Error fetching full name: $e");
    return 'No Name';
  }
}

Future<String?> getServiceType() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return null;
    }

    final userId = user.uid;
    final userRef =
        FirebaseFirestore.instance.collection('portfolio').doc(userId);

    // Fetch the document snapshot
    DocumentSnapshot doc = await userRef.get();

    // Check if the document exists and retrieve the service
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      String service = data?['service'] ?? 'No Service';
      return service;
    } else {
      print("Service document does not exist.");
      return 'No Service';
    }
  } catch (e) {
    print("Error fetching service type: $e");
    return 'No Service'; // Return a default service on error
  }
}

Future<String?> getEmail(String uid) async {
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      return snapshot.get('email') as String?;
    } else {
      return 'Error';
    }
  } catch (e) {
    return 'Error';
  }
}

Future<String?> uploadImage(File imageFile) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    String filePath = '${user.uid}/uploads/${DateTime.now()}.jpg';
    await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
    String downloadUrl =
        await FirebaseStorage.instance.ref(filePath).getDownloadURL();

    // Store the download URL in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('images')
        .add({
      'url': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return downloadUrl;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool> deleteImage(String imageUrl) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Get the reference to the image
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();

    // Delete the corresponding document from Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('images')
        .where('url', isEqualTo: imageUrl)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<List<String>> fetchUserFolio() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return [];
    }

    final userId = user.uid;
    final ref = FirebaseStorage.instance.ref().child('$userId/uploads/');

    // List all items in the directory
    final result = await ref.listAll();
    List<String> imageUrls = [];

    // Get download URLs for each image
    for (var item in result.items) {
      String downloadUrl = await item.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  } catch (e) {
    print("Error fetching user images: $e");
    return [];
  }
}

// Delete an image from Firebase Storage
Future<bool> deleteImageFolio(String imagePath) async {
  try {
    final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
    await storageRef.delete();
    return true;
  } catch (e) {
    print("Error deleting image: $e");
    return false;
  }
}

Future<String?> uploadImageFolio(File imageFile) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    String fileName =
        '${user.uid}/uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await FirebaseStorage.instance.ref(fileName).putFile(imageFile);
    String downloadUrl =
        await FirebaseStorage.instance.ref(fileName).getDownloadURL();

    // You can save the URL in Firestore if needed

    return downloadUrl; // Return the download URL
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
