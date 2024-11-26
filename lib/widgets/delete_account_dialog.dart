import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteDialog extends ConsumerWidget {
  final String title;
  final Function() onPressed;
  const DeleteDialog({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: Text(
        'Delete $title',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
      content: Text(
          "Are you sure you want delete your ${title.toLowerCase()}? All your ${title.toLowerCase()} data will be lost.",
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
                  onPressed: onPressed,
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