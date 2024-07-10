import 'package:flutter/material.dart';

class TranscriptionProvider with ChangeNotifier {
  String transcriptionText = "";

  void updateText(String text) {
    transcriptionText += text;
    notifyListeners();
  }

  void clearTranscription() {
    transcriptionText = '';
    notifyListeners();
  }
}
