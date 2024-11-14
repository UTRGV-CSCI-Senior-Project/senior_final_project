import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorBox extends StatelessWidget {
  final String errorMessage;
    final VoidCallback onDismiss;


  const ErrorBox({
    super.key,
    required this.errorMessage,
        required this.onDismiss,

  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return errorMessage.isNotEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onError,// Light red background
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.error),
            ),
            child: ListTile(
              leading:  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              title: Text(
                errorMessage,
                style:  GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              trailing: IconButton(
                icon:  Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                onPressed: onDismiss,
              ),
            ),
          )
        : Container();
  }
}
