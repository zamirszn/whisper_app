import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:whisper/services/database_helper.dart';

int maxTextLength = 200;

extension StringExtension on String {
  String toPascalCase() {
    if (isEmpty) {
      return '';
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

String formatRecordTime(int number) {
  String numberStr = number.toString();
  if (number < 10) {
    numberStr = '0$numberStr';
  }

  return numberStr;
}

Map<String, dynamic> params = {
  'model': 'nova-2-general',
  'detect_language': true,
  'filler_words': false,
  'punctuation': true,
};

Deepgram deepgram = Deepgram(const String.fromEnvironment('DEEPGRAMAPIKEY'),
    baseQueryParams: params);

void showTopSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: appColor1,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20), // Adjust the top margin to position it below the app bar
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Color appColor1 = Colors.green;
String? selectedLanguage;

String appName = "Transcription";

int maxtoken = 100;

const String usageTipsText = """
Tip for Best Results:

Speak Clearly and Audibly: Ensure your voice is clear and at a reasonable volume for the best transcription accuracy.
""";

final DatabaseHelper databaseHelper = DatabaseHelper.instance;

final List<Map<String, String>> languages = [
  {'name': 'Afrikaans', 'code': 'af'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Armenian', 'code': 'hy'},
  {'name': 'Azerbaijani', 'code': 'az'},
  {'name': 'Belarusian', 'code': 'be'},
  {'name': 'Bosnian', 'code': 'bs'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Chinese', 'code': 'zh'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'Galician', 'code': 'gl'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Hebrew', 'code': 'he'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Kazakh', 'code': 'kk'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Macedonian', 'code': 'mk'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Maori', 'code': 'mi'},
  {'name': 'Nepali', 'code': 'ne'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Persian', 'code': 'fa'},
  {'name': 'Polish', 'code': 'pl'},
  {'name': 'Portuguese', 'code': 'pt'},
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tagalog', 'code': 'tl'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];
