import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message){
  final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
