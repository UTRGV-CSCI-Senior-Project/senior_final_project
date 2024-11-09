import 'package:flutter/material.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:google_fonts/google_fonts.dart';

void verifyPasswordDialog(
    BuildContext context,
    String title,
    Function(String) onVerified,
  ) {
    final TextEditingController passwordController = TextEditingController();
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Please verify your password before continuing.',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      inputField(
                        'password-verify-field',
                        'Password',
                        'Enter your current password',
                        TextInputType.visiblePassword,
                        passwordController,
                        (value) {},
                        context,
                        isPassword: true,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await onVerified(passwordController.text);
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: isLoading
                            ? SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  strokeWidth: 5,
                                ),
                              )
                            : Text(
                                key: const Key('verify-password-button'),
                                'Verify',
                                style: GoogleFonts.inter(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                      )
                    ],
                  ),
                )),
              ),
            );
          });
        });
  }