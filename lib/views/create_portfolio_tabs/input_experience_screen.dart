import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InputExperience extends StatefulWidget {
  final Function(int, int) onExperienceEntered;
  final int initialYears;
  final int initialMonths;
  final String? title;
  final String? subTitle;
  const InputExperience(
      {super.key,
      required this.onExperienceEntered,
      this.initialYears = 0,
      this.initialMonths = 0,
      this.title,
      this.subTitle});

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
    yrsController.text = '${widget.initialYears}';
    monthController.text = '${widget.initialMonths}';
  }

  @override
  void dispose() {
    yrsController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20.0),
        Text(
          widget.title ?? "Let's get your profile ready!",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8.0),
        Text(
          widget.subTitle ?? 'How much experience do you have?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w300),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildInputColumn('Years', yrsController),
                const SizedBox(width: 10),
                _buildInputColumn('Months', monthController),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputColumn(String label, TextEditingController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w300)),
        Container(
          alignment: Alignment.center,
          height: 90,
          width: 90,
          child: TextField(
            cursorColor: Theme.of(context).colorScheme.primary,
            key: Key('$label-field'),
            style:
                GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
            onChanged: (value) {
              int enteredValue = int.tryParse(value) ?? 0;
              if (label == 'Years') {
                // Update years and handle months overflow
                int months = int.tryParse(monthController.text) ?? 0;
                // Update years
                int newYears = (int.tryParse(yrsController.text) ?? 0) + (months ~/ 12);
                yrsController.text = '$newYears';
                // Update months
                int newMonths = months % 12;
                monthController.text = '$newMonths';
                widget.onExperienceEntered(newYears, newMonths);
              } else {
                // Update months and handle months overflow
                int years = int.tryParse(yrsController.text) ?? 0;
                int newMonths = enteredValue + years * 12;
                int newYears = newMonths ~/ 12;
                newMonths = newMonths % 12;
                yrsController.text = '$newYears';
                monthController.text = '$newMonths';
                widget.onExperienceEntered(newYears, newMonths);
              }
            },
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }
}
