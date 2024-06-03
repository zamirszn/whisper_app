import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/onboarding/onboarding_screen.dart';

void main() {
  OpenAI.apiKey = whisperApiKey;
  runApp(const WhisperApp());
}

class WhisperApp extends StatelessWidget {
  const WhisperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark(),
        theme: ThemeData(
          fontFamily: "PulpDisplay",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LiquidSwipeOnboarding());
  }
}
