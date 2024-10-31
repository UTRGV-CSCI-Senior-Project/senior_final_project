import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget inputField(String key, String label, String hintText, TextInputType keyboardType,
    TextEditingController controller, Function(String) onChanged,
BuildContext context,     {bool isPassword = false}) {
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
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          
        ),
      ),
    ]),
  );

}