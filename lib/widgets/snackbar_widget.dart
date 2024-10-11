import 'package:flutter/material.dart';
import 'package:folio/constants/error_constants.dart';

void showCustomSnackBar(BuildContext context, String errorCode) {
  final errorMessage = ErrorConstants.getMessage(errorCode);

  final snackBar = SnackBar(
    dismissDirection: DismissDirection.vertical,
    duration: const Duration(seconds: 3),
    content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 100,
        decoration: const BoxDecoration(
            color: Color(0xFFC72C41),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/Error.png', scale: 1,),
            const Padding(padding: EdgeInsets.only(right: 16)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error!',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(
                  errorMessage,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ))
            
          ],
        )),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
