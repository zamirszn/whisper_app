import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_it/share_it.dart';
import 'package:whisper/globals.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    getAllTranscriptions();
    super.initState();
  }

  List<Map<String, dynamic>> dbTranscriptList = [];

  void getAllTranscriptions() async {
    final data = await databaseHelper.readAll();
    dbTranscriptList = data;
    setState(() {});
  }

  void _deleteText(int id) async {
    await databaseHelper.delete(id);
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
        itemCount: dbTranscriptList.length,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        itemBuilder: (context, index) {
          if (dbTranscriptList.isEmpty) {
            return const Center(child: Text("No transcription history"));
          } else {
            int historyId = dbTranscriptList[index]['id'];
            String historyText = dbTranscriptList[index]["content"];
            return Container(
              decoration: BoxDecoration(
                  color: appColor1.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child:
                          SelectableText(dbTranscriptList[index]['content'])),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
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
                          _deleteText(historyId);
                          dbTranscriptList.removeAt(index);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        });
  }
}
