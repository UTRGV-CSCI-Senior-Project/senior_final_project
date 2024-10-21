import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(0, 111, 253, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Folio",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 60,
                color: Color(0xFFFFFFFF),
                letterSpacing: 0.1, // 10% letterSpacing
              ),
            ),
          ],
        ),
      ),
    );
  }
}
