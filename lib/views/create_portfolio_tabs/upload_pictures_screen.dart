import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadPictures extends ConsumerStatefulWidget {
  final Function(List<File>) onImagesAdded;
  final List<File> selectedImages;

  const UploadPictures(
      {super.key, required this.onImagesAdded, required this.selectedImages});

  @override
  ConsumerState<UploadPictures> createState() => _UploadPicturesState();
}

class _UploadPicturesState extends ConsumerState<UploadPictures> {
  late List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _selectedImages =
        widget.selectedImages; // Initialize with the passed images
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Text(
              "Let's get your profile ready!",
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Add photos to your portfolio.',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 30.0),
            Expanded(child: _buildUI()),
          ],
        ),
      ),
      
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0, // Space between grid items
              mainAxisSpacing: 8.0,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  key: const Key('image-picker-button'),
                  onTap: () async {
                    final imagePicker = ref.watch(imagePickerProvider);
                    final List<XFile> images =
                        await imagePicker.pickMultiImage();

                    if (images.isNotEmpty) {
                      for (var image in images) {
                        _selectedImages.add(File(image.path));
                      }
                    }

                    widget.onImagesAdded(_selectedImages);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.withOpacity(0.1), width: 0),
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_rounded, color: Color.fromRGBO(0, 111, 253, 1), size: 50),
                    ),
                  ),
                );
              } else {
                final imageIndex = index - 1;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Optional: Rounded corners
                        child: Image.file(
                          _selectedImages[imageIndex],
                          fit: BoxFit
                              .cover, // Ensures the image covers the whole container
                        ),
                      ),
                    ),
                    Positioned(
                      key: Key('remove-image-$index'),
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.removeAt(imageIndex);
                          });
                          widget.onImagesAdded(_selectedImages);
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
