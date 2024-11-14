import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    // More configurable spin animation
  _spinController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(period: const Duration(milliseconds: 800));
  
  // Smoother scale animation
  _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.8,
    upperBound: 1.1,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              'FOLIO', // Add your app name here
              style: GoogleFonts.poppins(
                  fontSize: 60, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 0.5
                  ),
            ),

            RotationTransition(
              turns: _spinController,
              child: ScaleTransition(
                scale: _scaleController,
                child: Image.asset(
                  "assets/Explore.png",
                  width: 150,
                  height: 150,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
