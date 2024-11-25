import 'dart:async';

import 'package:countdown_memorial/AddDate.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'MainApp.dart';
import 'ad/ShowAdFun.dart';
import 'gg/LoadingOverlay.dart';

class StartPaper extends StatelessWidget {
  const StartPaper({super.key});

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
  final netController = TextEditingController();
  final LoadingOverlay _loadingOverlay = LoadingOverlay();
  late ShowAdFun adManager;

  @override
  void initState() {
    super.initState();
    netController.addListener(showCreteBut);
    netController.text = "1500";
    adManager = AppUtils.getMobUtils(context);
  }

  @override
  void dispose() {
    super.dispose();
    netController.removeListener(showCreteBut);
  }

  void showCreteBut() async {
    netController.text.trim();
  }

  void showAdNextPaper(AdWhere adWhere, Function() nextJump) async {
    if (!adManager.canShowAd(adWhere)) {
      adManager.loadAd(adWhere);
    }
    setState(() {
      _loadingOverlay.show(context);
    });
    AppUtils.showScanAd(context, adWhere, 5, () {
      setState(() {
        _loadingOverlay.hide();
      });
    }, () {
      setState(() {
        _loadingOverlay.hide();
      });
      nextJump();
    });
  }

  void saveToNextPaper() async {
    showAdNextPaper(AdWhere.SAVE, () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AddDate(type: 0)),
          (route) => route == null);
    });
  }

  void jumpToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainApp()),
        (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/bg_add.webp'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 430.0, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: Image.asset('assets/img/icon_add_tip.webp'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 103),
                child: GestureDetector(
                  onTap: () {
                    saveToNextPaper();
                  },
                  child: Container(
                    width: 145,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: const Center(
                      child: Text(
                        '+ ADD',
                        style: TextStyle(
                          color: Color(0xFFF15F82),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void restartApp(BuildContext context) {
    Navigator.of(context).removeRoute(ModalRoute.of(context) as Route);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StartPaper()),
        (route) => route == null);
  }
}
