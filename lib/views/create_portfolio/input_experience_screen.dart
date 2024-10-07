import 'package:flutter/material.dart';
import 'package:senior_final_project/views/create_portfolio/input_images_screen.dart';

class InputExperience extends StatefulWidget {
  final String serviceText;
  const InputExperience({Key? key, required this.serviceText})
      : super(key: key);

  @override
  State<InputExperience> createState() => _InputExperienceState();
}

class _InputExperienceState extends State<InputExperience> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          SafeArea(
            child: LinearProgressIndicator(
              value: 0.5,
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
          Text(
            'How much experience do you have? in ${widget.serviceText}',
            style: const TextStyle(
              fontSize: 18.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Year/s',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Month/s',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Spacer(),
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
                    MaterialPageRoute(builder: (context) => InputImages()),
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

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
