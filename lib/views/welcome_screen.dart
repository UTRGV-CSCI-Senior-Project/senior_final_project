import 'package:flutter/material.dart';
import 'package:senior_final_project/views/home_screen.dart';
import 'package:senior_final_project/views/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white60,
      body: ListView(
        children: [
          Text("APP Name"),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 0, 162, 255),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: TextButton(onPressed: () {
                }, child: Text('Login')),
              ),
              Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 0, 162, 255),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                }, child: Text('Sign up')),
              )
            ],
          )
        ],
      ),
    );
  }
}
