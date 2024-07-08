import 'package:flutter/material.dart';

void showTextDialog(BuildContext context, String? text) {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) => TextDialog(text: text),
  );
}

class TextDialog extends StatelessWidget {
  const TextDialog({super.key, required this.text});
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
            child: const Text("Ok"))
      ],
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SelectableText(
          text ?? "",
        ),
      ),
    );
  }
}
