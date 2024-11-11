import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/widgets/input_field_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String type;
  final String userId;

  const FeedbackScreen({
    super.key,
    required this.type,
    required this.userId,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _subjectFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();
  final  _scrollController = ScrollController();
  bool _isSubmitting = false;

    @override
  void initState(){
    _subjectFocusNode.addListener(() => _scrollToFocused(_subjectFocusNode));
    _messageFocusNode.addListener(() => _scrollToFocused(_messageFocusNode));

    super.initState();
  }

  // Get screen content based on type
  String get _screenTitle => widget.type == 'bug' ? 'Report a Bug' : 'Get Help';

  String get _subjectHint => widget.type == 'bug'
      ? 'Briefly describe the issue'
      : 'What do you need help with?';

  String get _messageHint => widget.type == 'bug'
      ? 'Please provide details about what happened and steps to reproduce the issue'
      : 'Please describe your question or concern in detail';

  Future<void> _submitFeedback() async {
    if(_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty){
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text(
                  'Please fill in all fields',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedbackRepo = ref.watch(feedbackRepositoryProvider);

      await feedbackRepo.sendFeedback(
        _subjectController.text,
        _messageController.text,
        widget.type,
        widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green[300],
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text(
                  widget.type == 'bug'
                      ? 'Thank you for reporting this bug!'
                      : 'Your help request has been submitted!',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text(
                  e is AppException ? e.message : 'Authentication Failed',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

 void _scrollToFocused(FocusNode focusNode){
    if (focusNode.hasFocus) {
      _scrollController.animateTo(
        150.0, // Adjust this value based on your UI layout
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_screenTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.type == 'bug'
                          ? 'Found something not working correctly?\nLet us know and we\'ll fix it!'
                          : 'Need assistance? We\'re here to help!',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    inputField(
                        'subject-field',
                        'Subject',
                        _subjectHint,
                        TextInputType.text,
                        _subjectController,
                        (value) {},
                        context, _subjectFocusNode),
                    const SizedBox(height: 8),
                    inputField(
                        'message-field',
                        'Message',
                        _messageHint,
                        TextInputType.multiline,
                        _messageController,
                        (value) {},
                        context, _messageFocusNode),
                    const SizedBox(height:50),

                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(width: double.infinity, padding: const EdgeInsets.all(10), child: ElevatedButton(
                      key: const Key('submit-feedback-button'),
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 4),
                            )
                          : Text(
                              widget.type == 'bug'
                                  ? 'Submit Bug Report'
                                  : 'Send',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                    ),),
        
        );
  }
}
