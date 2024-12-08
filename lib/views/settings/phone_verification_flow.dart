import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/widgets/sms_code_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneVerificationFlow extends ConsumerStatefulWidget {
  final String? initialPhoneNumber;
  const PhoneVerificationFlow({super.key, this.initialPhoneNumber});

  @override
  ConsumerState<PhoneVerificationFlow> createState() =>
      _PhoneVerificationFlowState();
}

class _PhoneVerificationFlowState extends ConsumerState<PhoneVerificationFlow> {
  String _phoneNumber = "";
  late PhoneNumber _isPhoneValid;
  bool _isLoading = false;

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
      if (mounted) {
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
      }
      if (mounted) {
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
    return StatefulBuilder(builder: (context, setState) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Text(
              'Add your phone number',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
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
                    key: const Key('phone-field'),
                    invalidNumberMessage: null,
                    initialCountryCode: 'US',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    dropdownIconPosition: IconPosition.trailing,
                    flagsButtonMargin: const EdgeInsets.all(10),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              style: TextButton.styleFrom(
 backgroundColor: _isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
              ),
              key: const Key('send-code-button'),
              onPressed: _isLoading ? null : () => _handlePhoneVerification(),
              child: _isLoading
                  ? SizedBox(
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
    });
  }
}
