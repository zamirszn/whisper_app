import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:whisper/globals.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;
  final void Function() onStart;
  final void Function(double amplitude) onAmplitudeChanged;

  const AudioRecorder(
      {super.key, required this.onStop, required this.onAmplitudeChanged, required this.onStart});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  // Amplitude? _amplitude;
  double? _amplitude;

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen(
      (amp) {
        // widget.onAmplitudeChanged(amp.current.abs());
        // _amplitude = amp.current.abs();
      },
    );

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        await _audioRecorder.start();
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  @override
  Widget build(BuildContext context) {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
            child: Material(
              color: _recordState != RecordState.stop
                  ? Colors.red.withOpacity(0.1)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              child: InkWell(
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: _recordState != RecordState.stop
                        ? const Icon(Icons.stop, color: Colors.red, size: 30)
                        : Icon(Icons.mic,
                            color: Theme.of(context).primaryColor, size: 30)),
                onTap: () {
                  (_recordState != RecordState.stop) ? _stop() : _start();

                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          if (_recordState == RecordState.record)
            Row(
              children: [
                ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: InkWell(
                      child: const SizedBox(
                          width: 56,
                          height: 56,
                          child:
                              Icon(Icons.pause, color: Colors.red, size: 30)),
                      onTap: () {
                        _pause();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          if (_recordState == RecordState.pause)
            Row(
              children: [
                ClipOval(
                  child: Material(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: InkWell(
                      child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.play_arrow,
                              color: Colors.green, size: 30)),
                      onTap: () {
                        _resume();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          _recordState != RecordState.stop
              ? Text(
                  '$minutes : $seconds',
                  style: TextStyle(color: appColor1),
                )
              : const Text("Tap to speak"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
