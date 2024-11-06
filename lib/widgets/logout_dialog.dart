import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: Text(
        'Log out',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
      content: Text(
          "Are you sure you want to log out? You'll need to login again to use the app.",
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
                  onPressed: () {
                    ref.watch(userRepositoryProvider).signOut();
                    Navigator.pop(context);
                  },
                  child: Text('LOGOUT',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            )
          ],
        )
      ],
    );
  }
}
