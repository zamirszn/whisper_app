import 'dart:io';

import 'package:dart_openai/dart_openai.dart';

Future sendAudio(String filePath) async {
  OpenAIAudioModel transcription =
      await OpenAI.instance.audio.createTranscription(
    file: File(filePath),
    model: "whisper-1",
    responseFormat: OpenAIAudioResponseFormat.json,
  );

// print the transcription.
  print(transcription.text);
}
