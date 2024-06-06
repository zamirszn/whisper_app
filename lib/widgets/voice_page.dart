import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/services/api_response.dart';
import 'package:whisper/services/whisper_service.dart';
import 'package:whisper/widgets/audio_recorder_widget.dart';
import 'package:whisper/widgets/fail_dialog.dart';
import 'package:whisper/widgets/language_selector.dart';
import 'package:whisper/widgets/player_widget.dart';
import 'package:whisper/widgets/ripple_effect_widget.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  bool showPlayer = false;
  String? audioPath;
  double? currentAmplitude;

  String? lastTranscribedText;

  @override
  void initState() {
    showPlayer = false;

    super.initState();
  }

  final GlobalKey<RipplesState> ripplesStateKey = GlobalKey<RipplesState>();

  void changeAnimationSpeed(int duration) {
    if (ripplesStateKey.currentState != null) {
      ripplesStateKey.currentState!
          .updateAnimationDuration(Duration(milliseconds: duration));
    }
  }

  List<String> transcribedTexts = [];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(
                color: Colors.grey.shade200,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Select Your Language",
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    LanguageSelector(),
                  ],
                ),
              ),
            ),
          ),
          if (lastTranscribedText == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Ripples(
                key: ripplesStateKey,
              ),
            ),
          if (lastTranscribedText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: appColor1.withOpacity(.1),
                  child: SizedBox(
                    // height: 400,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transcribedTexts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: AnimatedTextKit(
                              isRepeatingAnimation: false,
                              animatedTexts: [
                                TyperAnimatedText(transcribedTexts[index],
                                    textStyle: const TextStyle(fontSize: 20))
                              ]),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (showPlayer == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: PlayerWidget(
                source: audioPath!,
                onDelete: () {
                  setState(() => showPlayer = false);
                },
              ),
            ),
          // if (showPlayer == false)
          AudioRecorder(
            onStart: () {
              setState(() => showPlayer = false);
            },
            onAmplitudeChanged: (amplitude) {
              currentAmplitude = amplitude;
            },
            onStop: (path) {
              setState(() {
                audioPath = path;
                showPlayer = true;
              });
              connectToWhisper(audioPath!, context);
            },
          ),
        ],
      ),
    );
  }

  void connectToWhisper(String audio, context) async {
    var response = await sendAudio(audio);
    if (response is Success) {
      lastTranscribedText = response.message;
      if (lastTranscribedText != null) {
        transcribedTexts.add(lastTranscribedText!);
      }
      setState(() {});
    } else if (response is Failure) {
      showFailDialog(context, response.message);
    }
  }
}
