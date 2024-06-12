import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/services/api_response.dart';
import 'package:whisper/services/database_helper.dart';
import 'package:whisper/services/open_ai_service.dart';
import 'package:whisper/widgets/audio_recorder_widget.dart';
import 'package:whisper/widgets/fail_dialog.dart';
import 'package:whisper/widgets/language_selector.dart';
import 'package:whisper/widgets/player_widget.dart';
import 'package:whisper/widgets/ripple_effect_widget.dart';
import 'package:whisper/widgets/text_dialog.dart';

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

  bool _firstAutoscrollExecuted = false;
  bool _shouldAutoscroll = false;

  void _scrollListener() {
    _firstAutoscrollExecuted = true;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _shouldAutoscroll = true;
    } else {
      _shouldAutoscroll = false;
    }
  }

  @override
  void initState() {
    showPlayer = false;
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Ripples(),
            ),
          if (lastTranscribedText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: appColor1.withOpacity(.1),
                  child: SizedBox(
                    height: deviceSize.height / 2.3,
                    child: ListView.builder(
                      controller: _scrollController,
                      // physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transcribedTexts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: SelectableText(transcribedTexts[index],
                              style: const TextStyle(fontSize: 17)

                              // AnimatedTextKit(
                              //     isRepeatingAnimation: false,
                              //     animatedTexts: [
                              //       TyperAnimatedText(transcribedTexts[index],
                              //           textStyle:
                              //               const TextStyle(fontSize: 17))
                              //     ]),
                              ),
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
                  reset();
                },
              ),
            ),
          // if (showPlayer == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
              if (transcribedTexts.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    summarize(context);
                  },
                  child: const Text(
                    "Summarize",
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  void jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 100);
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   curve: Curves.easeOut,
      //   duration: const Duration(milliseconds: 500),
      // );
    }
  }

  void reset() {
    showPlayer = false;
    transcribedTexts.clear();
    lastTranscribedText = null;
    setState(() {});
  }

  void connectToWhisper(String audio, context) async {
    var response = await sendAudio(audio);
    if (response is Success && response.message != null) {
      correctGrammer(response.message!, context);
    } else if (response is Failure) {
      showFailDialog(context, response.message);
    }
  }

  void correctGrammer(String text, context) async {
    var response = await checkGrammer(text);
    if (response is Success) {
      lastTranscribedText = response.message;
      if (lastTranscribedText != null) {
        transcribedTexts.add(lastTranscribedText!);
      }
      saveTranscription(text);
      setState(() {});
      jumpToBottom();
    } else if (response is Failure) {
      showFailDialog(context, response.message);
    }
  }

  void summarize(context) async {
    String allTexts = transcribedTexts.join(' ');
    var response = await summarizeConversation(allTexts);

    if (response is Success) {
      showTextDialog(context, response.message ?? "");
    }
  }

  void saveTranscription(String text) async {
    await databaseHelper.add(text);
  }
}
