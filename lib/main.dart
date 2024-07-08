import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/onboarding/onboarding_screen.dart';
import 'package:whisper/providers/history_provider.dart';
import 'package:whisper/widgets/bottom_nav.dart';

void main() async {
  // Ensure all widgets are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  

  runApp(const TranscriptionApp());
}

class TranscriptionApp extends StatelessWidget {
  const TranscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
         ChangeNotifierProvider(
    create: (context, ) => HistoryProvider(),
  ),
      ],

      child: MaterialApp(
        
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          
          fontFamily: "PulpDisplay",
          colorScheme: ColorScheme.fromSeed(seedColor: appColor1),
          useMaterial3: true,
        ),
        home: const CheckOnboarding(), // Set CheckOnboarding as the home widget
      ),
    );
  }
}

class CheckOnboarding extends StatefulWidget {
  const CheckOnboarding({super.key});

  @override
  State<CheckOnboarding> createState() => _CheckOnboardingState();
}

class _CheckOnboardingState extends State<CheckOnboarding> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final nav = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboardingDone = prefs.getBool('onboardingDone');

    if (isOnboardingDone == true) {
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BottomNav(),
        ),
      );
    } else {
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LiquidSwipeOnboarding(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}
