import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/globals.dart';
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
    return handleError(e);
  }
}

Future<Object> checkGrammer(String text) async {
  try {
    final completion = await OpenAI.instance.completion.create(
        model: "gpt-3.5-turbo-instruct",
        prompt: "Correct the grammar of the following: $text",
        maxTokens: maxtoken);

    return Success(message: completion.choices.first.text.trim());
  } catch (e) {
    return handleError(e);
  }
}

Future<Object> summarizeConversation(String text) async {
  try {
    final completion = await OpenAI.instance.completion.create(
        model: "gpt-3.5-turbo-instruct",
        prompt: 'Summarize this text: $text',
        maxTokens: maxtoken);

    return Success(message: completion.choices.first.text.trim());
  } catch (e) {
    return handleError(e);
  }
}

Failure handleError(Object e) {
  if (e is SocketException) {
    return Failure(message: "Please check your internet connection");
  } else if (e is RequestFailedException) {
    return Failure(message: e.message);
  }
  return Failure(message: e.toString());
}
