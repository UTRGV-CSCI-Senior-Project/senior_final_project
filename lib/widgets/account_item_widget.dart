 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget accountItem({
    required String title,
    required BuildContext context,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(value, style: GoogleFonts.inter(fontSize: 15)),
            const SizedBox(
              width: 16,
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            )
          ],
        ),
      ),
    );
  }