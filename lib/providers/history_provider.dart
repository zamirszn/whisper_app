import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';

class HistoryProvider extends ChangeNotifier {
  static List<Map<String, dynamic>> _allTranscriptionListReadOnly = [];
  // when cant modify allTranscriptionListReadOnly because data from
  // DBs is read only

  List<Map<String, dynamic>> allTranscriptionList = [];

  void setTranscriptionList(List<Map<String, dynamic>> data) {
    _allTranscriptionListReadOnly = data;

    allTranscriptionList =
        List<Map<String, dynamic>>.from(_allTranscriptionListReadOnly);

    notifyListeners();
  }

  void getAllTranscriptions() async {
    final data = await databaseHelper.readAll();
    setTranscriptionList(data);
  }

  void saveTranscription(String text) async {
    int id = await databaseHelper.add(text);
    allTranscriptionList.add(
      {
        "id": id,
        "content": text,
      },
    );

    notifyListeners();
  }

  void removeHistory(int index, int historyId) async {
    await databaseHelper.delete(historyId);
    allTranscriptionList.removeAt(index);
    notifyListeners();
  }
}
