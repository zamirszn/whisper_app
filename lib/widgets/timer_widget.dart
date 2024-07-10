import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/providers/timer_provider.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(builder: (context, state, _) {
      return Text(
        '${state.minutes} : ${state.seconds}',
        style: TextStyle(color: appColor1),
      );
    });
  }
}
