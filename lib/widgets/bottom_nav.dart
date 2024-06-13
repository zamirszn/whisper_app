import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/widgets/history_page.dart';
import 'package:whisper/widgets/text_dialog.dart';
import 'package:whisper/widgets/voice_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  BottomNavState createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {
  @override
  void initState() {
    _initializeDatabase();
    checkIsTipsShown();
    super.initState();
  }

  void _initializeDatabase() async {
    await databaseHelper.database; // Ensure the database is initialized
  }

  void checkIsTipsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboardingDone = prefs.getBool('onboardingDone');
    if (isOnboardingDone == null || isOnboardingDone == false) {
      showUsageTips();
    }

    await prefs.setBool('onboardingDone', true);
  }

  void showUsageTips() async {
    if (mounted) {
      showTextDialog(context, usageTipsText);
    }
  }

  int _currentIndex = 0;

  final List<Widget> _children = const [
    VoicePage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
                showUsageTips();
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
