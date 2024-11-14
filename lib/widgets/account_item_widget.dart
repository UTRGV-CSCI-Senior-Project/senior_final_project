import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget accountItem({
  required String title,
  required BuildContext context,
  required String value,
  required VoidCallback onTap,
  int maxLines = 2, // You can adjust this
}) {
  return GestureDetector(
    key: Key(title),
    onTap: onTap,
    child: Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multiline
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 30,),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 16),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          )
        ],
      ),
    ),
  );
}