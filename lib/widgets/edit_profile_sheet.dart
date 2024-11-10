import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/widgets/error_widget.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void showEditProfileSheet(BuildContext context, UserModel userModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => EditProfileSheet(userModel: userModel),
  );
}

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel userModel;

  const EditProfileSheet({
    super.key,
    required this.userModel,
  });

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController usernameController;
  final _usernameFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _scrollController = ScrollController();

  File? file;
  bool isLoading = false;
  String errorMessage = "";
  bool deleteProfilePicture = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.userModel.fullName);
    usernameController = TextEditingController(text: widget.userModel.username);

    _usernameFocusNode.addListener(() => _scrollToFocused(_usernameFocusNode));
    _nameFocusNode.addListener(() => _scrollToFocused(_nameFocusNode));

    super.initState();
  }

  void _scrollToFocused(FocusNode focusNode){
    if (focusNode.hasFocus) {
      _scrollController.animateTo(
        150.0, // Adjust this value based on your UI layout
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void chooseProfilePicture() async {
    final ImagePicker imagePicker = ref.read(imagePickerProvider);
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      deleteProfilePicture = false;
      file = File(image.path);
    });
  }

  void _updateProfile() async {
    if (usernameController.text.isEmpty || nameController.text.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all necessary fields.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      Map<String, dynamic> updates = {};

      if (nameController.text != widget.userModel.fullName) {
        updates['fullName'] = nameController.text;
      }

      if (usernameController.text != widget.userModel.username) {
        if (!await ref
            .read(firestoreServicesProvider)
            .isUsernameUnique(usernameController.text)) {
          setState(() {
            errorMessage = "Username is taken, try a different one.";
            isLoading = false;
          });
          return;
        }

        updates['username'] = usernameController.text;
      }

      File? profilePicture;
      if (deleteProfilePicture) {
        updates['profilePictureUrl'] = null;
      } else if (file != null) {
        profilePicture = file;
      }

      if (updates.isNotEmpty || profilePicture != null) {
        await ref
            .read(userRepositoryProvider)
            .updateProfile(profilePicture: profilePicture, fields: updates);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        errorMessage =
            e is AppException ? e.message : "Failed to update profile";
        isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showDeleteButton = !deleteProfilePicture &&
        (file != null ||
            (widget.userModel.profilePictureUrl != null &&
                widget.userModel.profilePictureUrl!.isNotEmpty));

    return SingleChildScrollView(
      key: const Key('edit-profile-scrollable'),
      controller: _scrollController,
      child: 
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.bold
                  )
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                GestureDetector(
                  onTap: chooseProfilePicture,
                  child: Container(
                    height: 125,
                    width: 125,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: deleteProfilePicture
                        ? Icon(Icons.person,
                            size: 125,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.3))
                        : file != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child: Image.file(
                                  file!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : widget.userModel.profilePictureUrl != null &&
                                    widget
                                        .userModel.profilePictureUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Image.network(
                                      widget.userModel.profilePictureUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: 125,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 125,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withOpacity(0.3),
                                  ),
                  ),
                ),
                if (showDeleteButton)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                          width: 3,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.delete,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            file = null;
                            deleteProfilePicture = true;
                          });
                        },
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.create_rounded,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: chooseProfilePicture),
                    ),
                  )
              ],
            ),
            const SizedBox(
              height: 12,
            ), // Name Field
            inputField('name-field', 'Full Name', 'Full Name',
                TextInputType.text, nameController, (value) {
              setState(() {
                errorMessage = "";
              });
            }, context, _nameFocusNode),
            inputField('username-field', 'Username', 'Enter a unique username',
                TextInputType.text, usernameController, (value) {
              errorMessage = "";
            }, context, _usernameFocusNode),
            const SizedBox(height: 16),
            if (errorMessage.isNotEmpty)
              ErrorBox(
                  errorMessage: errorMessage,
                  onDismiss: () {
                    setState(() {
                      errorMessage = "";
                    });
                  }),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('update-button'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _updateProfile();
                },
                child: isLoading ? SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 5,
                          ),
                        ): Text('Save Changes', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),)
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    )
    ,);
    
  }
}
