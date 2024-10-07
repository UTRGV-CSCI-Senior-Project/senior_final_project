//File just to navigate to after successful sign/log in
//Can be changed

import 'package:flutter/material.dart';
import 'package:senior_final_project/views/create_portfolio/choose_service_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home Screen'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseService()),
              );
            },
            child: Text('Type of service'),
          )
        ],
      )),
    );
  }
}
