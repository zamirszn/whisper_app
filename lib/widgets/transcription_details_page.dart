import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whisper/globals.dart';

class TranscriptionDetailsPage extends StatelessWidget {
  const TranscriptionDetailsPage({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () async {
            showTopSnackBar(context, "Text copied");

            await Clipboard.setData(ClipboardData(text: text));
          },
          icon: const Icon(
            Icons.copy,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {
            SharePlus.instance.share(ShareParams(text: text));
          },
          icon: const Icon(
            Icons.share,
            size: 20,
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SelectableText(
            text,
          ),
        ),
      ),
    );
  }
}
