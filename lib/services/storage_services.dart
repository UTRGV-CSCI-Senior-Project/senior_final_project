import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';

class StorageServices {
  final Ref _ref;
  final FirebaseStorage _firebaseStorage;

  StorageServices(this._ref, this._firebaseStorage);

  Future<String?> uploadProfilePicture(File image) async {
    try {
      final uid = _ref.read(authStateProvider).value?.uid;

      if (uid == null) {
        throw 'no-user';
      }

      final storageRef = _firebaseStorage.ref().child('profile_pictures/$uid');

      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      
      return downloadUrl;
    } 
    catch (e) 
    {
      if (e == 'no-user') {
        rethrow;
      } else {
        throw 'pfp-error';
      }
    }
  }
}
