import 'dart:async';

import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';

import 'MainApp.dart';
import 'StartPaper.dart';
import 'gg/LTFDW.dart';

class Guide extends StatelessWidget {
  const Guide({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  Timer? _timerProgress;
  bool restartState = false;
  DateTime? _pausedTime;
  late LTFDW Ltfdw;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    startProgress();
    Ltfdw = LTFDW(
      onAppResumed: _handleAppResumed,
      onAppPaused: _handleAppPaused,
    );
    WidgetsBinding.instance.addObserver(Ltfdw);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
  }

  void _startProgress() {
    const int totalDuration = 2000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;

    int currentUpdate = 0;

    _timerProgress = Timer.periodic(Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
        pageToHome();
      }
    });
  }

  void pageToHome() {
    String? stringValue =
        LocalStorage().getValue(LocalStorage.dateList) as String?;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ((stringValue != null && stringValue.isNotEmpty)
                    ? MainApp()
                    : const StartPaper())),
        (route) => route == null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startProgress() {
    _controller.forward();
  }

  void stopProgress() {
    _controller.stop();
  }

  void resetProgress() {
    _controller.reset();
  }


  void _handleAppResumed() {
    LocalStorage.isInBack = false;
    if (_pausedTime != null) {
      final timeInBackground =
          DateTime.now().difference(_pausedTime!).inSeconds;
      if (LocalStorage.clone_ad == true) {
        return;
      }
      if (timeInBackground > 3 && LocalStorage.int_ad_show == false) {
        restartState = true;
        // restartApp();
      }
    }
  }

  void _handleAppPaused() {
    LocalStorage.isInBack = true;
    LocalStorage.clone_ad = false;
    _pausedTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/bg_start.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: Image.asset('assets/img/start_logo.webp'),
                    ),
                    const Text(
                      'Milestone Marker',
                      style: TextStyle(
                        fontFamily: 'ebgaramond',
                        fontSize: 28,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80,right: 102,left: 102),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProgressBar(
                        progress: _progress, // Set initial progress here
                        height: 6,
                        borderRadius: 3,
                        backgroundColor: Color(0xFF828282),
                        progressColor: Color(0xFF8572FF),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void restartApp() {
    AppUtils.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Guide()),
          (route) => false,
    );
  }

}

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBar({
    required this.progress,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}