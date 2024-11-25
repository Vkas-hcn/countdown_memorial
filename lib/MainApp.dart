import 'package:countdown_memorial/AddDate.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'SettingPaper.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Home(),
    const AddDate(type: 1),
    SettingPaper(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 内容区域
            Expanded(
              child: _pages[_selectedIndex],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/img/icon_main_btn.webp',
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 140,
                  color: Colors.transparent,
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          width: 32,
                          height: 32,
                          _selectedIndex == 0
                              ? 'assets/img/icon_home.webp'
                              : 'assets/img/icon_home_2.webp',
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Transform.translate(
                          offset: const Offset(0, -32),
                          child: Image.asset(
                            'assets/img/icon_main_add_2.webp',
                            width: 70,
                            height: 70,
                          ),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          width: 32,
                          height: 32,
                          _selectedIndex == 2
                              ? 'assets/img/icon_set_2.webp'
                              : 'assets/img/icon_set.webp',
                        ),
                        label: '',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.transparent,
                    unselectedItemColor: Colors.transparent,
                    onTap: _onItemTapped,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

