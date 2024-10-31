import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreDetailsScreen extends StatefulWidget {
  final Function(String) onDetailsEntered;
  const MoreDetailsScreen({
    super.key,
    required this.onDetailsEntered
  });

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {
  final detailsText = TextEditingController();

  @override
  void dispose(){
    detailsText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's get your profile ready!",
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Write any details for potential clients.",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black)
                  ),
                  child: TextField(
                    key: const Key('details-field'),
                    cursorColor: Colors.black,
                    onChanged: (value){
                      widget.onDetailsEntered(value);
                    },
                    controller: detailsText,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your details here...',
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}