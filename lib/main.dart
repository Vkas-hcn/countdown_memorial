import 'package:countdown_memorial/AddDate.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

import 'Guide.dart';
import 'gg/Get2Data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  LocalStorage().init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(providers: [
      Provider<Get2Data>(
        create: (_) => Get2Data(),
      ),
      ChangeNotifierProvider(create: (_) => Get2Data()),
    ], child: const MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppUtils.navigatorKey, // 设置全局 navigatorKey
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initializeApp();
    print("object=================main");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adUtils = Provider.of<Get2Data>(context, listen: false);
      Get2Data.initializeFqaId();
      adUtils.getBlackList(context);
      pageToHome();
    });
  }

  Future<void> initializeApp() async {
    await Firebase.initializeApp();
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  void pageToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Guide()),
        (route) => route == null);
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
        ),
      ),
    );
  }
}
