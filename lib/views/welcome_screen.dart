import 'package:flutter/material.dart';
import 'package:senior_final_project/core/service_locator.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
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
          const Text("APP Name"),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 162, 255),
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: TextButton(onPressed: () {
                }, child: const Text('Login')),
              ),
              Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 162, 255),
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: TextButton(
                  key: const Key('signup-button'),
                  onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen(userRepository: locator<UserRepository>(),)));
                }, child: const Text('Sign up')),
              )
            ],
          )
        ],
      ),
    );
  }
}
