import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.black, // Match your app's theme color
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {


  const ErrorView({
    super.key, 

  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try restarting the app',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }
}