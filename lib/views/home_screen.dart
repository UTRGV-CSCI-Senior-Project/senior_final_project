//File just to navigate to after successful sign/log in
//Can be changed

import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:senior_final_project/views/create_portfolio/choose_service_screen.dart';
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/welcome_screen.dart';
>>>>>>> origin/main

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
<<<<<<< HEAD
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
=======
  Widget build(BuildContext context, WidgetRef ref) {
    
    return   Scaffold(
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home Screen'),
          ElevatedButton(onPressed: (){
            ref.watch(userRepositoryProvider).signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
          }, child: const Text('Sign Out '))
>>>>>>> origin/main
        ],
      )),
    );
  }
}
