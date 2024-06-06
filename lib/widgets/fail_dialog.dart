import 'package:flutter/material.dart';

void showFailDialog(BuildContext context, String? text) {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) => FailDialog(text: text),
  );
}

class FailDialog extends StatelessWidget {
  const FailDialog({super.key, required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"))
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Text(
          text ?? "",
        ),
      ),
    );
  }
}
