import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:folio/services/upload_image_service.dart';
import 'package:folio/views/create_portfolio/more_details_screen.dart';

void main() {
  runApp(const UploadPictures(
    serviceText: '',
    yearsText: '0',
    monthsText: '0',
  ));
}

class UploadPictures extends StatefulWidget {
  final String serviceText;
  final String yearsText;
  final String monthsText;

  const UploadPictures({
    super.key,
    required this.serviceText,
    required this.yearsText,
    required this.monthsText,
  });

  @override
  _UploadPicturesState createState() => _UploadPicturesState();
}

class _UploadPicturesState extends State<UploadPictures> {
  User? user;
  final List<File> _selectedImages = [];
  List<String> _fetchedImages = [];
  bool _isUploading = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      user = FirebaseAuth.instance.currentUser;
      _loadFetchedImages();
    });
  }

  Future<void> _loadFetchedImages() async {
    setState(() {
      _isLoading = true;
    });
    _fetchedImages = await fetchImagesForUser();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SafeArea(
              child: LinearProgressIndicator(
                value: _isLoading ? null : 0.75,
                backgroundColor: Colors.grey,
                minHeight: 10.0,
                color: const Color.fromARGB(255, 0, 140, 255),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Let's get your profile ready!",
              style: TextStyle(
                fontSize: 20.0,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Upload Images',
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(child: _buildUI()),
          ],
        ),
      ),
      floatingActionButton: _uploadMediaButton(context),
      bottomNavigationBar: BottomAppBar(
        shadowColor: Colors.white,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MoreDetailsScreen(
                            serviceText: widget.serviceText,
                            yearsText: widget.yearsText,
                            monthsText: widget.monthsText,
                          )),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadMediaButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isUploading
          ? null
          : () async {
              List<File?> selectedImages = await getImagesFromGallery(context);
              if (selectedImages.isNotEmpty) {
                setState(() {
                  _selectedImages.addAll(selectedImages.whereType<File>());
                });
              }
            },
      child: const Icon(Icons.add_a_photo),
    );
  }

  Widget _buildUI() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _fetchedImages.isEmpty
                  ? const Center(child: Text('No images found.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                      ),
                      itemCount: _fetchedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.network(
                              _fetchedImages[index],
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool deleted = await deleteImageFromStorage(
                                      _fetchedImages[index]);
                                  if (deleted) {
                                    setState(() {
                                      _fetchedImages.removeAt(index);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
        ElevatedButton(
          onPressed: _selectedImages.isEmpty || _isUploading
              ? null
              : () async {
                  setState(() {
                    _isUploading = true;
                  });

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User is not signed in.')),
                    );
                    setState(() {
                      _isUploading = false;
                    });
                    return;
                  }

                  bool success = true;
                  for (File image in _selectedImages) {
                    success = success && await uploadFileForUser(image);
                  }
                  setState(() {
                    _isUploading = false;
                    if (success) {
                      _selectedImages.clear();
                    }
                  });
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All uploads successful!')),
                    );
                    _loadFetchedImages();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload failed.')),
                    );
                  }
                },
          child: const Text('Upload Selected Images'),
        ),
      ],
    );
  }
}
