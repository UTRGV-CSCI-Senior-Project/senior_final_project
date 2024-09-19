import 'package:flutter/material.dart';
import 'dart:async';
import "package:senior_final_project/views/welcome_screen.dart";

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime(); //comment this out to configure spalsh screen
  }

  startTime() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, navigateToDeviceScreen);
  }

  navigateToDeviceScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}
