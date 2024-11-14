import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pinput/pinput.dart';

class PhoneVerificationFlow extends ConsumerStatefulWidget {
  String? initialPhoneNumber;
  PhoneVerificationFlow({super.key, this.initialPhoneNumber});

  @override
  ConsumerState<PhoneVerificationFlow> createState() =>
      _PhoneVerificationFlowState();
}

class _PhoneVerificationFlowState extends ConsumerState<PhoneVerificationFlow> {
  final _phoneNumberFocusNode = FocusNode();
  String _phoneNumber = "";
  late PhoneNumber _isPhoneValid;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneVerification() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_phoneNumber.isEmpty ||
          !_isPhoneValid.isValidNumber() ||
          widget.initialPhoneNumber == _phoneNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text('Please enter a valid phone number.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
        return;
      }
      final verificationId =
          await ref.read(userRepositoryProvider).verifyPhone(_phoneNumber);
      String? smsCode = await getSmsCodeFromUser(context);

      if (smsCode == null) {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      await ref
          .read(userRepositoryProvider)
          .verifySmsCode(verificationId, smsCode);
      await ref.read(userRepositoryProvider).updateProfile(
          fields: {'phoneNumber': _phoneNumber, 'isPhoneVerified': true});
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green[300],
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text('Your phone number was updated successfully!',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text(
                  error is NumberTooShortException
                      ? 'The number entered is too short.'
                      : error is AppException
                          ? error.message
                          : 'There was an error verifying your number, try again later.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              centerTitle: true,
              title: Text(
                "Add your phone number",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Please enter your phone number.\n\nWe will send a 6 digit code to the provided number.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IntlPhoneField(
                        invalidNumberMessage: null,
                        initialCountryCode: 'US',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        dropdownIconPosition: IconPosition.trailing,
                        flagsButtonMargin: const EdgeInsets.all(10),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        languageCode: "en",
                        onChanged: (phone) {
                          setState(() {
                            _isPhoneValid = phone;
                            _phoneNumber = phone.completeNumber;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: _isLoading ? null : () => _handlePhoneVerification(),
                child: _isLoading
                    ?  SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 5,
                        ),
                      )
                    : Text(
                        key: const Key('phone-number-button'),
                        'Send Code',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
