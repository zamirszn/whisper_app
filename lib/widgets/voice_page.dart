import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/providers/history_provider.dart';
import 'package:whisper/providers/timer_provider.dart';
import 'package:whisper/providers/transcription_provider.dart';
import 'package:whisper/services/deep_gram_service.dart';
import 'package:whisper/widgets/fail_dialog.dart';
import 'package:whisper/widgets/ripple_effect_widget.dart';
import 'package:whisper/widgets/text_dialog.dart';
import 'package:whisper/widgets/recorder_widget.dart';
import 'package:whisper/widgets/timer_widget.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  @override
  void setState(fn) {
    print("calling setState");
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _recordSub = mic.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    super.initState();
  }

  RecordState _recordState = RecordState.stop;

  Stream<DeepgramSttResult>? stream;

  AudioRecorder mic = AudioRecorder();
  StreamSubscription<RecordState>? _recordSub;

  List<int> audioChunkBuffer = [];

  void handleListenEvent(Uint8List data) {
    // Convert Uint8List to List<int>
    List<int> audioBuffer = data.toList();

    // Now you can use audioBuffer as needed
    audioChunkBuffer.addAll(audioBuffer);
  }

  void startStream() async {
    await mic.hasPermission();

    Stream<Uint8List> audioStream = await mic.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    audioStream.listen(
      (Uint8List audioInUint8List) {},
      onDone: () {},
      onError: (error) {
        if (kDebugMode) {
          print('Error: $error');
        }
      },
    );

    final Map<String, Object> liveParams = {
      'detect_language': false, // not supported by streaming API
      'language': 'en',
      // must specify encoding and sample_rate according to the audio stream
      'encoding': 'linear16',
      'sample_rate': 16000,
    };

    stream = deepgram.transcribeFromLiveAudioStream(audioStream,
        queryParams: liveParams);

    stream?.listen(
        (res) {
          Provider.of<TranscriptionProvider>(context, listen: false)
              .updateText("${res.transcript} ");
          jumpToButtom();
        },
        cancelOnError: true,
        onError: (error) {
          if (mounted) {
            showFailDialog(context, error.toString());
          }
        });

    if (mounted) {
      Provider.of<TimerProvider>(context, listen: false).startTimer();
    }
  }

  void stopStream() async {
    await mic.stop();
    saveLastTranscriptToDB();
  }

  Future<void> _pause() async {
    Provider.of<TimerProvider>(context, listen: false).pauseTimer();
    await mic.pause();
  }

  void initStream() {
    reset();
    startStream();
  }

  Future<void> _resume() async {
    startStream();
    Provider.of<TimerProvider>(context, listen: false).resumeTimer();

    await mic.resume();
  }

  @override
  void dispose() {
    Provider.of<TimerProvider>(context, listen: false).stopTimer();
    _recordSub?.cancel();
    mic.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  void jumpToButtom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<TranscriptionProvider>(context, listen: false)
                    .updateText(
                        "More more more text More more more textMore more more textMore more more textMore more more text ");
                jumpToButtom();

                // showTextDialog(context, usageTipsText);
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer<TranscriptionProvider>(builder: (context, state, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.transcriptionText.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Ripples(),
                ),
              if (state.transcriptionText.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: appColor1.withOpacity(.1),
                      child: SizedBox(
                          height: deviceSize.height / 1.8,
                          width: deviceSize.width / 1.2,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: SelectableText(
                                  state.transcriptionText.toPascalCase(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ))),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (state.transcriptionText.isNotEmpty &&
                        _recordState == RecordState.stop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (state.transcriptionText.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                summarizeText(context, state.transcriptionText);
                              },
                              child: const Text(
                                "Summarize",
                              ),
                            )
                        ],
                      ),
                  ],
                ),
              ),

              //recorder widget

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    StartStopRecordWidget(
                      recordState: _recordState,
                      onTap: () {
                        _recordState != RecordState.stop
                            ? stopStream()
                            : initStream();
                      },
                    ),
                    const SizedBox(width: 20),
                    if (_recordState == RecordState.record)
                      PauseWidget(
                        onPause: () => _pause(),
                      ),
                    if (_recordState == RecordState.pause)
                      ResumeWidget(
                        onResume: () => _resume(),
                      ),
                    _recordState != RecordState.stop
                        ? const TimerWidget()
                        : const Text("Tap to speak"),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void saveLastTranscriptToDB() {
    TranscriptionProvider state =
        Provider.of<TranscriptionProvider>(context, listen: false);
    if (state.transcriptionText.isNotEmpty || state.transcriptionText != "") {
      showTopSnackBar(context, "Saving transcription");

      Provider.of<HistoryProvider>(context, listen: false)
          .saveTranscription(state.transcriptionText);
    }
  }

  void reset() {
    Provider.of<TranscriptionProvider>(context, listen: false)
        .clearTranscription();

    Provider.of<TimerProvider>(context, listen: false).stopTimer();
    audioChunkBuffer.clear();
  }
}
