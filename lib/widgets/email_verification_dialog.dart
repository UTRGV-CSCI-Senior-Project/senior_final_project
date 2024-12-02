import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerificationDialog extends ConsumerWidget {
  final String? message;
  const EmailVerificationDialog({super.key, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: Text(
        'Verify Email',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
      content: Text(message ??
          "Your email address has not been verified yet. Would you like to us to send a verification link to your email?",
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onTertiary)),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                key: const Key('no-verification-button'),
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 3),
                ),
                child: Text('No',
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
                  onPressed: () {
                    ref.watch(userRepositoryProvider).sendEmailVerification();
                    Navigator.pop(context);
                  },
                  child: Text('Send',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            )
          ],
        )
      ],
    );
  }
}