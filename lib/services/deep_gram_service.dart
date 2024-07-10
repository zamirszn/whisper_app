
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:whisper/widgets/text_dialog.dart';


Future<void> summarizeText(context, String transcriptionText) async {
  if (transcriptionText.isNotEmpty) {
    const String url =
        'https://api.deepgram.com/v1/read?summarize=true&language=en';
    const String token = String.fromEnvironment('DEEPGRAMAPIKEY');
    String text = transcriptionText;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String summaryText = jsonResponse['results']['summary']['text'];
        showTextDialog(context, summaryText);
      } else {
        showTextDialog(context, 'Error: ${response.reasonPhrase}');

        if (kDebugMode) {
          print('Error: ${response.reasonPhrase}');
        }
        // Handle error response
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception caught: $e');
      }
      showTextDialog(context, 'Exception caught: $e');

      // Handle exceptions
    }
  }
}
