import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/loading_screen.dart';
import 'package:folio/views/onboarding_screen.dart';
import 'package:folio/views/welcome_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userStreamProvider).when(data: (userModel){
      if(userModel == null){
        return const WelcomeScreen();
      }
      if(userModel.completedOnboarding){
        return Scaffold(
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home Screen'),
          ElevatedButton(onPressed: (){
            ref.watch(userRepositoryProvider).signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
          }, child: const Text('Sign Out '))
        ],
      )),
    );
      }else{
        return const OnboardingScreen();
      }

    }, error: (s, p) => const LoadingScreen(), loading: () => const LoadingScreen());
  }
}