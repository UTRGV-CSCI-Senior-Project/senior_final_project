import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 76, 96, 139),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "APP NAME",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 48.0,
                color: Color(0xFFFFFFFF),
                letterSpacing: 0.1, // 10% letterSpacing
              ),
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 111, 253)) ,
              
            )
          ],
        ),
      ),
    );
  }
}
