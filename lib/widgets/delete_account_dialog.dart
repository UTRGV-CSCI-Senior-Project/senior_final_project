import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/widgets/verify_password_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountDialog extends ConsumerWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: Text(
        'Delete Account',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
      content: Text(
          "Are you sure you want delete your account? All your data will be lost.",
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onTertiary)),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 3),
                ),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error
                ),
                  onPressed: () {
                    verifyPasswordDialog(context, 'Verify Password',
                      (password) async {
                    try {
                      await ref
                          .watch(userRepositoryProvider)
                          .reauthenticateUser(password);

                        await ref
                            .watch(userRepositoryProvider)
                            .deleteUserAccount();
                      if(context.mounted){
                        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                      }
                      } catch (e) {
                        if(context.mounted) {
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
                  },
                  child: Text('DELETE',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            )
          ],
        )
      ],
    );
  }
}