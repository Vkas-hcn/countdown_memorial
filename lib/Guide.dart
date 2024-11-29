import 'dart:async';

import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

import 'MainApp.dart';
import 'StartPaper.dart';
import 'ad/ShowAdFun.dart';
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
  double _progress = 0.0;
  Timer? _timerProgress;
  bool restartState = false;
  DateTime? _pausedTime;
  late LTFDW Ltfdw;
  late ShowAdFun adManager;
  final _ump = UserMessagingPlatform.instance;
  final String _testDeviceId = "76A730E9AE68BD60E99DF7B83D65C4B4";
  late StreamSubscription _umpStateSubscription;
  final Duration checkInterval = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    adManager = ShowAdFun(context);
    requestConsentInfoUpdate();
    Ltfdw = LTFDW(
      onAppResumed: _handleAppResumed,
      onAppPaused: _handleAppPaused,
    );
    WidgetsBinding.instance.addObserver(Ltfdw);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProgress();
    });
  }

  void loadingGuideAd() {
    //延迟1秒
    Future.delayed(const Duration(seconds: 2), () {
      adManager.loadAd(AdWhere.OPEN);
      adManager.loadAd(AdWhere.BACKINT);
      adManager.loadAd(AdWhere.SAVE);
      showOpenAd();
    });
  }

  void _startMonitoringUmpState() {
    _umpStateSubscription = Stream.periodic(checkInterval).listen((_) async {
      bool umpState =
          await LocalStorage().getValue(LocalStorage.umpState) ?? false;
      if (umpState) {
        _umpStateSubscription.cancel();
        _startProgress();
        loadingGuideAd();
      }
    });
  }

Future<void> requestConsentInfoUpdate() async {
  bool? data = await LocalStorage().getValue(LocalStorage.umpState);
  print("requestConsentInfoUpdate---${data}");
  if (data == true) {
    loadingGuideAd();
    return;
  }
  _startMonitoringUmpState();

  int retryCount = 0;
  const maxRetries = 1;

  while (retryCount <= maxRetries) {
    try {
      final info = await _ump.requestConsentInfoUpdate(_buildConsentRequestParameters());
      print("requestConsentInfoUpdate---->${info.consentStatus}");
      if (info.consentStatus == ConsentStatus.required) {
        showConsentForm();
      } else {
        LocalStorage().setValue(LocalStorage.umpState, true);
      }
      break;
    } catch (e) {
      if (e is PlatformException && e.code == 'timeout') {
        retryCount++;
        if (retryCount > maxRetries) {
          LocalStorage().setValue(LocalStorage.umpState, true);
          return;
        }
        print("Request timed out, retrying... ($retryCount/$maxRetries)");
        await Future.delayed(Duration(seconds: 1));
      } else {
        LocalStorage().setValue(LocalStorage.umpState, true);
        return;
      }
    }
  }
}


  ConsentRequestParameters _buildConsentRequestParameters() {
    final parameters = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      debugSettings: ConsentDebugSettings(
        geography: DebugGeography.EEA,
        testDeviceIds: [_testDeviceId],
      ),
    );
    return parameters;
  }

  Future<void> showConsentForm() {
    return _ump.showConsentForm().then((info) {
      print("showConsentForm---->${info.consentStatus}");
      LocalStorage().setValue(LocalStorage.umpState, true);
    });
  }

  void showOpenAd() async {
    int elapsed = 0;
    const int timeout = 12000;
    const int interval = 500;
    print("准备展示open广告");
    Timer.periodic(const Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      if (adManager.canShowAd(AdWhere.OPEN)) {
        adManager.showAd(context, AdWhere.OPEN, () {
          print("关闭广告-------");
          pageToHome();
        });
        timer.cancel();
      } else if (elapsed >= timeout) {
        print("超时，直接进入首页");
        pageToHome();
        timer.cancel();
      }
    });
  }

  void _startProgress() {
    const int totalDuration = 12000; // Total duration in milliseconds
    const int updateInterval = 50; // Update interval in milliseconds
    const int totalUpdates = totalDuration ~/ updateInterval;
    int currentUpdate = 0;
    _progress = 0.0;
    _timerProgress =
        Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      setState(() {
        _progress = (currentUpdate + 1) / totalUpdates;
      });
      currentUpdate++;
      if (currentUpdate >= totalUpdates) {
        _timerProgress?.cancel();
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
    super.dispose();
  }

  void startProgress() {}

  void stopProgress() {}

  void resetProgress() {}

  void _handleAppResumed() {
    LocalStorage.isInBack = false;
    if (_pausedTime != null) {
      final timeInBackground =
          DateTime.now().difference(_pausedTime!).inSeconds;
      print("_handleAppResumed==LocalStorage.clone_ad=${LocalStorage.clone_ad}----LocalStorage.int_ad_show=${LocalStorage.int_ad_show}");
      if (LocalStorage.clone_ad == true) {
        return;
      }
      if (timeInBackground > 3 && LocalStorage.int_ad_show == false) {
        restartState = true;
        restartApp();
      }
    }
  }

  void _handleAppPaused() {
    print("_handleAppPaused------------");
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
                padding:
                    const EdgeInsets.only(bottom: 80, right: 102, left: 102),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProgressBar(
                        progress: _progress,
                        // Set initial progress here
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
