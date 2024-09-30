import 'package:flutter/material.dart';

Widget inputField(String key, String label, String hintText, TextInputType keyboardType,
    TextEditingController controller,
    {bool isPassword = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const Padding(padding: EdgeInsets.only(bottom: 5)),
      TextField(
        key: Key(key),
        controller: controller,
        cursorColor: const Color.fromARGB(255, 0, 111, 253),
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 0, 111, 253), width: 2.3)),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 104, 97, 97), width: 2)),
        ),
      ),
    ]),
  );

}