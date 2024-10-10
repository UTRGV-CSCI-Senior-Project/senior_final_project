//File just to navigate to after successful sign/log in
//Can be changed

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/services/edit_profile_services.dart';
import 'package:folio/views/create_portfolio/choose_service_screen.dart';
import 'package:folio/views/edit_profile.dart';
import 'package:folio/views/welcome_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final Future<bool> isProfessional = isProfessionalStatus();
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home Screen'),
          ElevatedButton(
              onPressed: () {
                ref.watch(userRepositoryProvider).signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()));
              },
              child: const Text('Sign Out ')),
          ElevatedButton(
              onPressed: () async {
                // Fetch the professional status
                bool isProfessional = await isProfessionalStatus();

                // Navigate based on the status
                if (isProfessional) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseService()),
                  );
                }
              },
              child: const Text('Edit Profile'))
        ],
      )),
    );
  }
}
