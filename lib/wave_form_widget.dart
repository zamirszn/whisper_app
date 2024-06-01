import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

class WaveFormWidget extends StatelessWidget {
  const WaveFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = IOS9SiriWaveformController(
      amplitude: 0.5,
      speed: 0.15,
    );
    return Transform.scale(
      scale: 2,
      child: SiriWaveform.ios9(
        controller: controller,
        options: const IOS9SiriWaveformOptions(
            height: 300, width: 100, showSupportBar: true),
      ),
    );
  }
}
