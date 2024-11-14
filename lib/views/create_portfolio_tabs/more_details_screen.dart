import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreDetailsScreen extends StatefulWidget {
  final Function(String) onDetailsEntered;
  final String initialDetails;
  final String? title;
  final String? subTitle;
  const MoreDetailsScreen({
    super.key,
    required this.onDetailsEntered,
    this.initialDetails = "",
    this.title,
    this.subTitle
  });

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {
  final detailsText = TextEditingController();

  @override
  void initState() {
    super.initState();
    detailsText.text = widget.initialDetails;
  }

  @override
  void dispose(){
    detailsText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title ??
                "Let's get your profile ready!",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8.0),
              Text(widget.subTitle ??
                "Write any details for potential clients.",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    textAlign: TextAlign.start,
                    key: const Key('details-field'),
                    cursorColor: Theme.of(context).colorScheme.primary,
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
          );
  }
}