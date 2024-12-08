import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestLocationDialog extends StatelessWidget {
  const RequestLocationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: Text(
            'Location Permission',
            style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onTertiary),
          ),
          content: Text(
            'Folio would like to access your location to provide personalized features. Would you like to allow this?',
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
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3),
                    ),
                    child: Text('Deny',
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
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Allow',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                )
              ],
            )
          ],
        );
  }
}