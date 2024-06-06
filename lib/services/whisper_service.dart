import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/services/api_response.dart';

Future<Object> sendAudio(String filePath) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode =
      prefs.getString('selectedLanguage') ?? 'en'; // Default language code
  try {
    OpenAIAudioModel transcription =
        await OpenAI.instance.audio.createTranscription(
      file: File(filePath),
      model: "whisper-1",
      language: languageCode,
      responseFormat: OpenAIAudioResponseFormat.json,
    );
    return Success(message: transcription.text);
  } catch (e) {
    print(e);
    if (e is SocketException) {
      return Failure(message: "Please check your internet connection");
    }
    return Failure(message: e.toString());
  }
}
