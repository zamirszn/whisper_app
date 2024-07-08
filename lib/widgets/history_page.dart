import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:share_it/share_it.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/providers/history_provider.dart';
import 'package:whisper/widgets/text_dialog.dart';
import 'package:whisper/widgets/transcription_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    Provider.of<HistoryProvider>(context, listen: false).getAllTranscriptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
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
      body: Consumer<HistoryProvider>(builder: (context, state, _) {
        return MasonryGridView.builder(
            itemCount: state.allTranscriptionList.length,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) {
              if (state.allTranscriptionList.isEmpty) {
                return const Center(child: Text("No transcription history"));
              } else {
                int historyId = state.allTranscriptionList[index]['id'];
                String historyText =
                    state.allTranscriptionList[index]["content"];
                return Container(
                  decoration: BoxDecoration(
                      color: appColor1.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10)),
                  margin:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(
                            historyText.length > maxTextLength
                                ? '${historyText.substring(0, maxTextLength)}...'
                                : historyText,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      TranscriptionDetailsPage(
                                    text: state.allTranscriptionList[index]
                                        ["content"],
                                  ),
                                ));
                              },
                              icon: const Icon(
                                Icons.visibility,
                                size: 17,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                showTopSnackBar(context, "Text copied");

                                await Clipboard.setData(
                                    ClipboardData(text: historyText));
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 17,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ShareIt.text(content: historyText);
                              },
                              icon: const Icon(
                                Icons.share,
                                size: 17,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                state.removeHistory(index, historyId);
                              },
                              icon: const Icon(
                                Icons.delete_rounded,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            });
      }),
    );
  }
}
