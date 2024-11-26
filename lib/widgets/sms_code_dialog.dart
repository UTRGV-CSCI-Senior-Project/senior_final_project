import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class SmsCodeDialog extends StatefulWidget {
  const SmsCodeDialog({super.key});

  @override
  State<SmsCodeDialog> createState() => _SmsCodeDialogState();
}

class _SmsCodeDialogState extends State<SmsCodeDialog> {
  final _smsController = TextEditingController();

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.grey[400]!),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(width: 2, color: Theme.of(context).colorScheme.tertiary),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );

    return AlertDialog(
      title: Text(
        'Verification',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the code sent to your number.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Pinput(
                key: const Key('pinput-field'),
                  length: 6,
                  controller: _smsController,
                  pinAnimationType: PinAnimationType.scale,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: defaultPinTheme,
                  showCursor: true,
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 2,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ],
                  )),
            ],
          )),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 3),
                ),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: TextButton(
                key: const Key('submit-sms-button'),
                  onPressed: () {
                    Navigator.of(context).pop(_smsController.text);
                  },
                  child: Text('SUBMIT',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            )
          ],
        )
      ],
    );
  }
}

Future<String?> getSmsCodeFromUser(BuildContext context) async {
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => const SmsCodeDialog(),
  );

  return result;
}
