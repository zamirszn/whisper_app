import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class PauseWidget extends StatelessWidget {
  const PauseWidget({
    super.key,
    required this.onPause,
  });
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Material(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: InkWell(
              child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.pause, color: Colors.red, size: 30)),
              onTap: () {
                onPause();
              },
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class ResumeWidget extends StatelessWidget {
  const ResumeWidget({
    super.key,
    required this.onResume,
  });
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Material(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: InkWell(
              child: const SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.play_arrow, color: Colors.green, size: 30)),
              onTap: () {
                onResume();
              },
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class StartStopRecordWidget extends StatelessWidget {
  const StartStopRecordWidget({
    super.key,
    required RecordState recordState,
    required this.onTap,
  }) : _recordState = recordState;

  final RecordState _recordState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
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
            onTap();
          },
        ),
      ),
    );
  }
}
