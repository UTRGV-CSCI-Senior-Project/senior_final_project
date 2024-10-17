import 'dart:ffi';

import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color.fromRGBO(0, 111, 253, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40,),
            const Text(
              "Folio",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 72.0,
                color: Color(0xFFFFFFFF),
                letterSpacing: .1, // 10% letterSpacing
              ),
            ),
            const Spacer(),
            Image.asset("assets/Explore.png",width: 250,height: 250,),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white) ,
              
            ),
            const SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }
}
