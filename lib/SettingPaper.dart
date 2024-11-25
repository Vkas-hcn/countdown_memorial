import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class SettingPaper extends StatelessWidget {
  const SettingPaper({super.key});

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

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();

  }




  void _restartApp() {
    restartApp(context);
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
                image: AssetImage('assets/img/bg_setting.webp'),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned(
                  top: 50.0,
                  left: 20,
                  child: Text(
                    'Setting',
                    style: TextStyle(
                      fontFamily: 'ebgaramond',
                      fontSize: 28,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100, right: 20, left: 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launchURL();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              image: const DecorationImage(
                                image: AssetImage('assets/img/bg_pp.webp'), // 替换为背景图片路径
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Row(
                                children: [
                                  Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF999999),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            launchUserAgreement();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              image: const DecorationImage(
                                image: AssetImage('assets/img/bg_pp.webp'), // 替换为背景图片路径
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Row(
                                children: [
                                  Text(
                                    "User Agreement",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF999999),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));
  }

  void launchURL() async {
    const url = 'https://milestonemarker.com/privacy/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      AppUtils.showToast('Cant open web page $url');
    }
  }

  void launchUserAgreement() async {
    const url =
        'https://milestonemarker.com/terms/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      AppUtils.showToast('Cant open web page $url');
    }
  }

  void restartApp(BuildContext context) {
    Navigator.of(context).removeRoute(ModalRoute.of(context) as Route);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SettingPaper()),
        (route) => route == null);
  }
}

