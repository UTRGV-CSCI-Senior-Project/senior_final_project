import 'package:flutter/material.dart';
import 'package:senior_final_project/constants/error_constants.dart';

void showCustomSnackBar(BuildContext context, String errorCode){
  final errorMessage = ErrorConstants.getMessage(errorCode);

  final snackBar = SnackBar(duration: const Duration(seconds: 3), content: Text(errorMessage), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
