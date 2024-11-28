import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class InvalidServiceDialog extends ConsumerWidget {
  final String? evaluationResult;

  const InvalidServiceDialog({super.key, this.evaluationResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      title: Text(
        'Invalid Service',
        style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
      content: Text(
        evaluationResult ?? "The service you provided is invalid.",
        style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onTertiary),
      ),
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
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
