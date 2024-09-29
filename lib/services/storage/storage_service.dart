import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class StorageService with ChangeNotifier {
  final firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;

  //Getters
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  //Read Images
  Future<void> fetchImages() async {
    _isLoading = true;

    //get list under the directory: uid/
    final ListResult result = await firebaseStorage.ref('uid/').listAll();

    //get the download URLs
    final urls =
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    //update URLs
    _imageUrls = urls;

    _isLoading = false;

    //update UI
    notifyListeners();
  }

  //Delete Images
  Future<void> deleteImages(String imageUrl) async {
    try {
      //remove from local list
      _imageUrls.remove(imageUrl);

      //get pathname and delete
      final String path = extractPathFromUrl(imageUrl);

      await firebaseStorage.ref(path).delete();
    } catch (error) {
      print("Error deleting image: $error");
    }

    //update UI
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);

    String encodedPath = uri.pathSegments.last;

    return Uri.decodeComponent(encodedPath);
  }

  //upload Images
  Future<void> uploadImages() async {
    _isUploading = true;
    notifyListeners();

    //pick an image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    File file = File(image.path);

    try {
      //define the path in storage
      String filePath = 'uid/${DateTime.now()}.png';

      //upload to firebase
      await firebaseStorage.ref(filePath).putFile(file);

      //fetch the url
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      //update the image urls and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (error) {
      print("Error in uploading image: $error");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
