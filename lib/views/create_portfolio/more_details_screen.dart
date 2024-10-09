import 'package:flutter/material.dart';
import 'package:folio/services/upload_image_service.dart';

void main() {
  runApp(const MoreDetailsScreen(
    serviceText: '',
    yearsText: '0',
    monthsText: '0',
  ));
}

class MoreDetailsScreen extends StatefulWidget {
  final String serviceText;
  final String yearsText;
  final String monthsText;

  const MoreDetailsScreen(
      {super.key,
      required this.serviceText,
      required this.yearsText,
      required this.monthsText});

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {
  final detailsText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SafeArea(
              child: LinearProgressIndicator(
                value: 1,
                backgroundColor: Colors.grey,
                minHeight: 10.0,
                color: const Color.fromARGB(255, 0, 140, 255),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Let's get your profile ready!",
              style: TextStyle(
                fontSize: 20.0,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Almost done.',
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Row(
              children: [Text('More Details: (optional)')],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(width: 10.0),
                Expanded(
                  // Use Expanded to allow proper spacing
                  child: TextField(
                    controller: detailsText,
                    decoration: const InputDecoration(
                      labelText: 'Write here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 10.0),
                    ),
                    minLines: 1,
                    maxLines: 10,
                  ),
                ),
                const SizedBox(width: 10.0),
              ],
            ),
            const SizedBox(height: 10.0),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shadowColor: Colors.white,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                await savePortfolioDetails(
                  widget.serviceText,
                  widget.yearsText,
                  widget.monthsText,
                  detailsText.text,
                );
                // Show a message when the Next button is clicked
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All done!'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blue,
                fixedSize: const Size(150, 50),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
