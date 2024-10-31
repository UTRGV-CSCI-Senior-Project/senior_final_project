import 'package:flutter/material.dart';

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
              color: Colors.red.withOpacity(0.1), // Light red background
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text(
                errorMessage,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onDismiss,
              ),
            ),
          )
        : Container();
  }
}
