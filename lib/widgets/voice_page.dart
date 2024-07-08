import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/providers/history_provider.dart';
import 'package:whisper/widgets/fail_dialog.dart';
import 'package:whisper/widgets/player_widget.dart';
import 'package:whisper/widgets/ripple_effect_widget.dart';
import 'package:whisper/widgets/text_dialog.dart';
import 'package:http/http.dart' as http;

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  bool showPlayer = false;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    _recordSub = mic.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });
    super.initState();
  }

  String? audioPath;
  RecordState _recordState = RecordState.stop;

  Stream<DeepgramSttResult>? stream;

  AudioRecorder mic = AudioRecorder();
  StreamSubscription<RecordState>? _recordSub;

  final StreamController<Uint8List> audioStreamController =
      StreamController<Uint8List>();

  // Collect the audio data in a list

  void startStream() async {
    await mic.hasPermission();

    Stream<Uint8List> audioStream = await mic.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    List<Uint8List> audioDataChunk = [];

    // audioStream.listen(
    //   (audioInUint8List) {
    //     audioDataChunk.add(audioInUint8List);
    //   },
    //   onDone: () {
    //     // When the stream is closed, close the controller
    //     audioStreamController.close();
    //     // now lets process the audio stream data
    //     // processAndSaveAudio(audioDataChunk);
    //   },
    //   onError: (error) {
    //     // Handle any errors
    //     if (kDebugMode) {
    //       print('Error: $error');
    //     }
    //     audioStreamController.close();
    //   },
    // );

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
          transcriptionText += "${res.transcript} ";

          if (mounted) {
            setState(() {});
          }

          jumpToBottom();
        },
        cancelOnError: true,
        onError: (error) {
          print("${error}here");
          if (mounted) {
            showFailDialog(context, error.toString());
          }
        });

    _startTimer();
  }

  Future<void> processAndSaveAudio(List<Uint8List> audioChunks) async {
    // Combine all chunks into a single Uint8List
    int totalLength =
        audioChunks.fold<int>(0, (total, chunk) => total + chunk.length);
    Uint8List combinedData = Uint8List(totalLength);
    int offset = 0;
    for (Uint8List chunk in audioChunks) {
      combinedData.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // Save the audio as a temporary file
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath =
        '${tempDir.path}/recorded_audio.wav'; // Change the extension to match the audio format

    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(combinedData);

    audioPath = tempPath;

    print('Audio saved to temporary file: $tempPath');
    setState(() {});
  }

  int _recordDuration = 0;
  Timer? _timer;

  String transcriptionText = "";

  void stopStream() async {
    showPlayer = true;
    await mic.stop();
    saveLastTranscriptToDB();
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await mic.pause();
  }

  void initStream() {
    try {
      startStream();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _resume() async {
    initStream();

    _startTimer();
    await mic.resume();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _timer?.cancel();
    _recordSub?.cancel();
    mic.dispose();
    audioStreamController.close();
    super.dispose();
  }

  bool firstAutoscrollExecuted = false;
  bool shouldAutoscroll = false;
  final ScrollController _scrollController = ScrollController();

  void jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + 100);
    }
  }

  void _scrollListener() {
    firstAutoscrollExecuted = true;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      shouldAutoscroll = true;
    } else {
      shouldAutoscroll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final String minutes = formatRecordTime(_recordDuration ~/ 60);
    final String seconds = formatRecordTime(_recordDuration % 60);

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
                showTextDialog(context, usageTipsText);
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (transcriptionText.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Ripples(),
              ),
            if (transcriptionText.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: appColor1.withOpacity(.1),
                    child: SizedBox(
                        height: deviceSize.height / 1.9,
                        width: deviceSize.width / 1.2,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: SelectableText(
                                  transcriptionText.toPascalCase()),
                            ))),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (showPlayer == true && _recordState == RecordState.stop)
                    ClipOval(
                      child: Material(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: InkWell(
                          child: const SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(Icons.refresh)),
                          onTap: () {
                            reset();
                          },
                        ),
                      ),
                    ),
                  if (transcriptionText.isNotEmpty &&
                      _recordState == RecordState.stop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (transcriptionText.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              summarizeText(context);
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
              padding: const EdgeInsets.symmetric(vertical: 30),
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
                                ? const Icon(Icons.stop,
                                    color: Colors.red, size: 30)
                                : Icon(Icons.mic,
                                    color: Theme.of(context).primaryColor,
                                    size: 30)),
                        onTap: () {
                          (_recordState != RecordState.stop)
                              ? stopStream()
                              : initStream();

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
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: InkWell(
                              child: const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(Icons.pause,
                                      color: Colors.red, size: 30)),
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
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
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
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 10),
            //   child: PlayerWidget(
            //     source: audioPath!,
            //     onDelete: () {
            //       reset();
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void saveLastTranscriptToDB() {
    if (transcriptionText.isNotEmpty) {
      showTopSnackBar(context, "Saving transcription");

      Provider.of<HistoryProvider>(context, listen: false)
          .saveTranscription(transcriptionText);
    }
  }

  void reset() {
    transcriptionText = "";
    _recordDuration = 0;
    showPlayer = false;
    setState(() {});
  }

  Future<void> summarizeText(context) async {
    if (transcriptionText.isNotEmpty) {
      const String url =
          'https://api.deepgram.com/v1/read?summarize=true&language=en';
      const String token = String.fromEnvironment('DEEPGRAMAPIKEY');
      String text = transcriptionText;

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'text': text}),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          String summaryText = jsonResponse['results']['summary']['text'];
          showTextDialog(context, summaryText);
        } else {
          showTextDialog(context, 'Error: ${response.reasonPhrase}');

          print('Error: ${response.reasonPhrase}');
          // Handle error response
        }
      } catch (e) {
        print('Exception caught: $e');
        showTextDialog(context, 'Exception caught: $e');

        // Handle exceptions
      }
    }
  }
}
