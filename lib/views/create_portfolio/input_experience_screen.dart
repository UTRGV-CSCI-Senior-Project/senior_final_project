import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior_final_project/views/create_portfolio/upload_pictures_screen.dart';

class InputExperience extends StatefulWidget {
  final String serviceText;

  const InputExperience({Key? key, required this.serviceText})
      : super(key: key);

  @override
  State<InputExperience> createState() => _InputExperienceState();
}

class _InputExperienceState extends State<InputExperience> {
  final TextEditingController yrsController = TextEditingController(text: '0');
  final TextEditingController monthController =
      TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
  }

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
          const SizedBox(height: 20.0),
          const Text(
            "Let's get your profile ready!",
            style: TextStyle(
              fontSize: 20.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 140.0),
          Text(
            'How much experience do you have in ${widget.serviceText}?',
            style: const TextStyle(
              fontSize: 18.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  controller: yrsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Year/s',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  controller: monthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Month/s',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 10.0),
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
                // Capture the input data
                String yearsText = yrsController.text;
                String monthsText = monthController.text;

                // Pass the data to the UploadPictures screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPictures(
                      serviceText: widget.serviceText,
                      yearsText: yearsText,
                      monthsText: monthsText,
                    ),
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
