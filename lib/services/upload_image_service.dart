import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> signInUserAnon() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Sign in with temporary account. UID:${userCredential.user?.uid}");
  } catch (e) {
    print("Error signing in: $e");
  }
}

Future<List<File?>> getImagesFromGallery(BuildContext context) async {
  List<File?> selectedImages = [];
  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images != null) {
      for (var image in images) {
        selectedImages.add(File(image.path));
      }
    }
  } catch (e) {
    print("Error picking images: $e");
  }
  return selectedImages;
}

Future<bool> uploadFileForUser(File file) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return false;
    }

    final userId = user.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split("/").last;
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    final uploadRef = storageRef.child("$userId/uploads/$timestamp-$fileName");
    await uploadRef.putFile(file);

    return true;
  } catch (e) {
    print("Error uploading file: $e");
  }
  return false;
}

// Fetch images from Firebase Storage
Future<List<String>> fetchImagesForUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userId = user.uid;
    final storageRef = FirebaseStorage.instance.ref().child("$userId/uploads");

    // List all items in the uploads folder
    final result = await storageRef.listAll();

    // Map items to their download URLs
    List<String> downloadUrls = [];
    for (var item in result.items) {
      final downloadUrl = await item.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  } catch (e) {
    print("Error fetching images: $e");
    return [];
  }
}

// Delete an image from Firebase Storage
Future<bool> deleteImageFromStorage(String imagePath) async {
  try {
    final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
    await storageRef.delete();
    return true;
  } catch (e) {
    print("Error deleting image: $e");
    return false;
  }
}

Future<void> savePortfolioDetails(String serviceText, String yearsText,
    String monthsText, String detailsText) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not signed in.");
      return;
    }

    final userId = user.uid;
    final portfolioRef = FirebaseFirestore.instance.collection('portfolio');

    // Create a document with the user's UID as the document ID
    await portfolioRef.doc(userId).set({
      'service': serviceText,
      'years': yearsText,
      'months': monthsText,
      'details': detailsText,
    });

    print("Portfolio details saved successfully.");
  } catch (e) {
    print("Error saving portfolio details: $e");
  }
}
