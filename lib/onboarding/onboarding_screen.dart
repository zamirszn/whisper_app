import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper/globals.dart';
import 'package:whisper/onboarding/liquid_card_swipe.dart';
import 'package:whisper/onboarding/liquid_swipe_view.dart';
import 'package:whisper/widgets/bottom_nav.dart';
import 'package:whisper/widgets/voice_page.dart';

class LiquidSwipeOnboarding extends StatefulWidget {
  const LiquidSwipeOnboarding({super.key});

  @override
  State<LiquidSwipeOnboarding> createState() => _LiquidSwipeOnboardingState();
}

class _LiquidSwipeOnboardingState extends State<LiquidSwipeOnboarding> {
  final _key = GlobalKey<LiquidSwipeState>();

  LiquidSwipeState? get liquidSwipeController => _key.currentState;

  bool isLastPage = false;
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidSwipe(
        key: _key,
        children: [
          /// First page
          LiquidSwipeCard(
            onTapName: () {},
            onSkip: () async {
              goHome();
            },
            name: appName,
            action: "Skip",
            image: const AssetImage("assets/images/image1.jpg"),
            title: "SpeakEasy",
            subtitle: "Empowering Communication ",
            body: "Revolutionize the way you interact with the world ",
            buttonColor: appColor1,
            titleColor: Colors.grey.shade700,
            subtitleColor: Colors.grey.shade900,
            bodyColor: appColor1,
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          /// Second page
          LiquidSwipeCard(
            onTapName: () => liquidSwipeController?.previous(),
            onSkip: () async {
              goHome();
            },
            name: "Back",
            action: "Done",
            image: const AssetImage("assets/images/image2.jpg"),
            title: "Effortless",
            subtitle: "Experience",
            body:
                "Our innovative speech-to-text solution offers precise and real-time transcription",
            buttonColor: Colors.white,
            titleColor: Colors.grey.shade500,
            subtitleColor: Colors.grey.shade200,
            bodyColor: Colors.white.withOpacity(0.8),
            gradient: LinearGradient(
              colors: [Colors.grey, appColor1],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ],
      ),
    );
  }

  void goHome() async {
    final navigator = Navigator.of(context);

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) => const BottomNav(),
      ),
    );
    

    
  }
}
