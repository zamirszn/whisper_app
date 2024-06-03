import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/services/whisper_service.dart';
import 'package:whisper/widgets/audio_recorder_widget.dart';
import 'package:whisper/widgets/player_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPlayer = false;
  String? audioPath;
  double? currentAmplitude;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: showPlayer == true
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PlayerWidget(
                    source: audioPath!,
                    onDelete: () {
                      setState(() => showPlayer = false);
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () {
                      connectToWhisper(audioPath!);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 150,
                        child: ColoredBox(
                          color: appColor1.withOpacity(.5),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Send"),
                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.send)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              )
            : AudioRecorder(
                onAmplitudeChanged: (amplitude) {
                  currentAmplitude = amplitude;
                },
                onStop: (path) {
                  setState(() {
                    audioPath = path;
                    showPlayer = true;
                  });
                },
              ),
      ),
    );
  }

  void connectToWhisper(String audio) {
    sendAudio(audio);
  }
}
