import 'package:flutter/material.dart';
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
    return ListView.builder(
      itemCount: dbTranscriptList.length,
      itemBuilder: (context, index) {
        return Container(
          child: Text(dbTranscriptList[index]['content']),
        );
      },
    );
  }
}
