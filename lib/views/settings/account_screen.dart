import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/widgets/account_item_widget.dart';
import 'package:folio/widgets/delete_account_dialog.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:folio/widgets/phone_dialog.dart';
import 'package:folio/widgets/update_email_dialog.dart';
import 'package:folio/widgets/verify_password_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends ConsumerWidget {
  final UserModel user;
  const AccountScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Account',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      accountItem(
                          title: 'Username',
                          context: context,
                          value: user.username,
                          onTap: () => showEditProfileSheet(context, user)),
                      const SizedBox(
                        height: 12,
                      ),
                      accountItem(
                          title: 'Full Name',
                          context: context,
                          value: user.fullName ?? '',
                          onTap: () => showEditProfileSheet(context, user)),
                      const SizedBox(
                        height: 12,
                      ),
                      accountItem(
                          title: 'Email',
                          context: context,
                          value: user.email,
                          onTap: () => {
                                verifyPasswordDialog(context, 'Verify Password', "Please verify your password before updating your account's email address.",
                                    (password) async {
                                  try {
                                    // Call your reauthenticate method here
                                    await ref
                                        .read(userRepositoryProvider)
                                        .reauthenticateUser(password);
                                    // If reauthentication successful, show email update dialog
                                    if (context.mounted) {
                                      updateAccountDialog(
                                        context,
                                        'Change Email',
                                        'What would you like to change your email to?\n\nA new verification link will be sent to the new email. The update will not be processed until you have verified that email.',
                                        user.email,
                                        (newEmail) async {
                                          try {
                                            await ref
                                                .read(userRepositoryProvider)
                                                .changeUserEmail(newEmail);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.green[300],
                                                  showCloseIcon: true,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Verification email sent to $newEmail',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary),
                                                  ),
                                                ),
                                              );
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                  showCloseIcon: true,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                      e is AppException
                                                          ? e.message
                                                          : 'Error sending the verification email.',
                                                      style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary)),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            showCloseIcon: true,
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                                e is AppException
                                                    ? e.message
                                                    : 'Authentication Failed',
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary))),
                                      );
                                    }
                                  }
                                })
                              }),
                      const SizedBox(
                        height: 12,
                      ),
                      accountItem(
                        title: 'Password',
                        context: context,
                        value: '',
                        onTap: () {
                          verifyPasswordDialog(context, 'Verify Password', "Please verify your current password before creating your new password.",
                              (newPassword) async {
                            try {
                              await ref
                                  .read(userRepositoryProvider)
                                  .reauthenticateUser(newPassword);
                              if (context.mounted) {
                                updateAccountDialog(
                                    context,
                                    'Update Password',
                                    'Create a new password.\n\nYour password should be at least 8 characters long and include a mix of letters, numbers, and special characters',
                                    '', (newPassword) async {
                                  try {
                                    await ref
                                        .read(userRepositoryProvider)
                                        .updateUserPassword(newPassword);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green[300],
                                          showCloseIcon: true,
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            'Your password was successfully updated!',
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          ),
                                        ),
                                      );
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            showCloseIcon: true,
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                                e is AppException
                                                    ? e.message
                                                    : 'Password update failed, try again later, or contact support.',
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary))),
                                      );
                                    }
                                  }
                                });
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      showCloseIcon: true,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                          e is AppException
                                              ? e.message
                                              : 'Authentication Failed',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary))),
                                );
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      accountItem(
                          title: 'Phone Number',
                          context: context,
                          value: user.phoneNumber ?? '',
                          onTap: () {
                            verifyPasswordDialog(context, 'Verify Password', "Please verify your password before adding your phone number.",
                                (password) async {
                              try {
                                await ref
                                    .watch(userRepositoryProvider)
                                    .reauthenticateUser(password);
                                if (context.mounted) {
                                  await showDialog(
                                    useSafeArea: false,
                                      context: context,
                                      builder: (BuildContext context) =>
                                           PhoneVerificationFlow(initialPhoneNumber: user.phoneNumber,));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            e is AppException
                                                ? e.message
                                                : 'Failed to add phone number. Try again later.',
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary))),
                                  );
                                }
                              }
                            });
                          })
                    ],
                  ),
                ))),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => DeleteDialog(
                        title: 'Account',
                        onPressed: () {
                          verifyPasswordDialog(context, 'Verify Password', "Please verify your password before deleting your account.\n\nWe need to make sure it's you!",
                              (password) async {
                            try {
                              await ref
                                  .watch(userRepositoryProvider)
                                  .reauthenticateUser(password);

                              await ref
                                  .watch(userRepositoryProvider)
                                  .deleteUserAccount();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/welcome', (route) => false);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      showCloseIcon: true,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                          e is AppException
                                              ? e.message
                                              : 'Account deletion failed.',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary))),
                                );
                              }
                            }
                          });
                        }));
              },
              child: Text(
                'DELETE ACCOUNT',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ));
  }
}
