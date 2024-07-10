import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider with ChangeNotifier {
  int _recordDuration = 0;
  Timer? _timer;

  int get recordDuration => _recordDuration;

  String get minutes => _formatRecordTime(_recordDuration ~/ 60);
  String get seconds => _formatRecordTime(_recordDuration % 60);

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _recordDuration = 0;
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    startTimer();
  }

  String _formatRecordTime(int time) {
    return time < 10 ? '0$time' : '$time';
  }
}
