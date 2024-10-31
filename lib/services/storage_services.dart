import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';

class StorageServices {
  final Ref _ref;
  final FirebaseStorage _firebaseStorage;

  StorageServices(this._ref, this._firebaseStorage);

  Future<String?> uploadProfilePicture(File image) async {
    try {
      final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw AppException('no-user');
      }

      final storageRef = _firebaseStorage.ref().child('profile_pictures/$uid');

      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (e is AppException && e.code == 'no-user') {
        rethrow;
      } else {
        throw AppException('pfp-upload-error');
      }
    }
  }

  Future<List<Map<String, String>>> uploadFilesForUser(List<File> files) async {
    final List<Map<String, String>> imageData = [];
    try {
      final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw AppException('no-user');
      }

      final storageRef = _firebaseStorage.ref();

      for (final file in files) {
        final fileName = file.path.split("/").last;
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final filePath = "portfolios/$uid/uploads/$timestamp-$fileName";
        final uploadRef = storageRef.child(filePath);
        await uploadRef.putFile(file);

        final downloadUrl = await uploadRef.getDownloadURL();
        imageData.add({
          'filePath': filePath,
          'downloadUrl': downloadUrl
        });
      }

      return imageData;
    } catch (e) {
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('upload-files-error');
      }
    }
  }

  // Fetch images from Firebase Storage
  Future<List<String>> fetchImagesForUser() async {
    try {
      final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw AppException('no-user');
      }

      final storageRef =
          _firebaseStorage.ref().child("portfolios/$uid/uploads");

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
      if (e is AppException && e.code == 'no-user') {
        rethrow;
      } else {
        throw AppException('fetch-images-error');
      }
    }
  }

  // Delete an image from Firebase Storage
Future<void> deleteImage(String imagePath) async {
  try {
    final storageRef = _firebaseStorage.ref().child(imagePath);
    await storageRef.delete();
  } catch (e) {
    throw AppException('delete-image-error');
  }
}

  Future<void> deletePortfolio() async {
    try{
      final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw AppException('no-user');
      }

      final storageRef = _firebaseStorage.ref().child('portfolios/$uid/uploads');

      final result = await storageRef.listAll();

      for(var item in result.items){
        await item.delete();
      }
    }catch (e){
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('delete-portfolio-error');
      }
    }
  }


}
