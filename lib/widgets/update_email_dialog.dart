import 'package:flutter/material.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:google_fonts/google_fonts.dart';

void updateAccountDialog(BuildContext context, String title, String description,
    String value, Function(String) onFinish) {
  final TextEditingController dialogController = TextEditingController();
  final focusNode = FocusNode();

  bool isLoading = false;
  showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                centerTitle: true,
                title: Text(
                  title,
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              body: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  // Add this wrapper
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        description,
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      inputField(
                          'dialog-field',
                          title.split(' ')[1],
                          'Enter new ${title.split(' ')[1].toLowerCase()}',
                          TextInputType.text,
                          dialogController,
                          (value) {},
                          context,
                          focusNode),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.3), // Replace Spacer with fixed height
                    ],
                  ),
                ),
              )),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  style: TextButton.styleFrom(
                     backgroundColor: isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
                  ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await onFinish(dialogController.text);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 5,
                            ),
                          )
                        : Text(
                            key: const Key('dialog-button'),
                            'Update',
                            style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
              ),
            ),
          );
        });
      });
}
