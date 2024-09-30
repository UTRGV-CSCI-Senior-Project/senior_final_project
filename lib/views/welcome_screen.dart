import 'package:flutter/material.dart';
import 'package:senior_final_project/views/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen(
                                    isLogin: true,
                                  )));
                    },
                    child: const Text('Login')),
              ),
              Container(
                  width: screenWidth - 40,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 162, 255),
                        width: 3,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Consumer(builder: (context, ref, child) {
                    return TextButton(
                        key: const Key('signup-button'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen(
                                        isLogin: false,
                                      )));
                        },
                        child: const Text('Sign up'));
                  }))
            ],
          )
        ],
      ),
    );
  }
}
