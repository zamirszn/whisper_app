import 'package:flutter/material.dart';

void showTextDialog(BuildContext context, String? text) {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) => TextDailog(text: text),
  );
}

class TextDailog extends StatelessWidget {
  const TextDailog({super.key, required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Text(
          text ?? "",
        ),
      ),
    );
  }
}
