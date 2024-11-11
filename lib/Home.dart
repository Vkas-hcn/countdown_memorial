import 'dart:math';

import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DetailPage.dart';
import 'bean/EventManager.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    print("Home----initState");
      getListData();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("Home----deactivate");
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Home----didUpdateWidget");
  }

  @override
  void dispose() {
    super.dispose();
    print("Home----dispose");
  }

  void getListData() async {
    await EventManager.loadEvents();
    setState(() {}); // Call setState after data is loaded to rebuild the UI
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
              image: AssetImage('assets/img/bg_main.webp'),
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
                  'Home',
                  style: TextStyle(
                    fontFamily: 'ebgaramond',
                    fontSize: 28,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (EventManager.events.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: EventManager.events.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPage(event: EventManager.events[index]),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      getListData();
                                    });
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12),
                                      child: FutureBuilder<ImageProvider>(
                                        future: AppUtils.getImageProvider(EventManager.events[index].bgUrl),
                                        builder: (context, snapshot) {
                                          return Container(
                                            width: double.infinity,
                                            height: 170,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              image: DecorationImage(
                                                image: snapshot.hasData
                                                    ? snapshot.data!
                                                    : AssetImage('assets/placeholder.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    maxLines: 2,
                                                    EventManager.events[index].name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF010101),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          AppUtils.timestampToYMD(EventManager.events[index].date),
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Color(0xFF646668),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: AppUtils.getCountDownWidget(
                                                      EventManager.events[index].style,
                                                      EventManager.events[index].date,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(top: 122.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "No records yet.",
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  void ResultApp(BuildContext context, String num) {}
}
