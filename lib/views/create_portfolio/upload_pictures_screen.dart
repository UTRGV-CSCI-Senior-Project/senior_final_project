import 'dart:io';
import 'package:flutter/material.dart';
import 'package:senior_final_project/services/upload_image_service.dart';

void main() {
  runApp(const UploadPictures());
}

class UploadPictures extends StatelessWidget {
  const UploadPictures({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Images',
        ),
        centerTitle: true,
      ),
      body: _buildUI(),
      floatingActionButton: _uploadMediaButton(context),
    );
  }

  Widget _uploadMediaButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        File? selectedImage = await getImageFromGallery(context);
        if (selectedImage != null) {
          bool success = await uploadFileForUser(selectedImage);
          print(success);
        }
      },
      child: const Icon(
        Icons.upload,
      ),
    );
  }

  Widget _buildUI() {
    return Container();
  }
}
