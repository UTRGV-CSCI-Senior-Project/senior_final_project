import 'package:flutter/material.dart';
import 'package:senior_final_project/views/create_portfolio/profile_preview_screen.dart';

class InputImages extends StatefulWidget {
  const InputImages({super.key});

  @override
  State<InputImages> createState() => _InputImagesState();
}

class _InputImagesState extends State<InputImages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          SafeArea(
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey,
              minHeight: 10.0,
              color: const Color.fromARGB(255, 0, 140, 255),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            "Let's get your profile ready!",
            style: TextStyle(
              fontSize: 20.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 140.0,
          ),
          const Text(
            'Upload some pictures of your work!',
            style: TextStyle(
              fontSize: 18.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
        ]),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePreviewScreen()),
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
            ]),
      ),
    );
  }
}
