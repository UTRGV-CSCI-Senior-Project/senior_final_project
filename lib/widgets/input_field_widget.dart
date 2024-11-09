import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget inputField(String key, String label, String hintText, TextInputType keyboardType,
    TextEditingController controller, Function(String) onChanged,
BuildContext context,     {bool isPassword = false}) {

    bool isMultiline = keyboardType == TextInputType.multiline;

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const Padding(padding: EdgeInsets.only(bottom: 5)),
      TextField(
        onChanged: onChanged,
        key: Key(key),
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.primary,
        obscureText: isPassword,
        keyboardType: keyboardType,
         maxLines: isMultiline ? 6 : 1,  // Will show 6 lines for multiline
          minLines: isMultiline ? 4 : 1,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
          contentPadding: isMultiline 
              ? const EdgeInsets.symmetric(vertical: 16, horizontal: 12)
              : null,
        ),
      ),
    ]),
  );

}