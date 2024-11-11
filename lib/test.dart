import 'dart:async';

import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class Event {
  final String id;
  final String name;
  final String bgUrl;
  final String style;
  final DateTime date;

  Event({
    required this.id,
    required this.name,
    required this.bgUrl,
    required this.style,
    required this.date,
  });
}

// 假设这是你的 EventManager 类
class EventManager {
  static Event getEventById(String id) {
    // 获取更新的 Event 实例逻辑
    // 这里返回一个示例对象，你需要替换为实际数据逻辑
    return Event(
      id: id,
      name: "Updated Event Name",
      bgUrl: "assets/img/sample_image.webp",
      style: "sample_style",
      date: DateTime.now(),
    );
  }
}

// DetailPage 使用 StatefulWidget，以便可以在数据更新时触发 UI 刷新
class DetailPage extends StatefulWidget {
  final Event event;

  const DetailPage({super.key, required this.event});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Event event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailPageScreen(
        event: event,
        onEventUpdated: (updatedEvent) {
          setState(() {
            event = updatedEvent;
          });
        },
      ),
    );
  }
}

// DetailPageScreen 中包含 onEventUpdated 回调以通知父级更新数据
class DetailPageScreen extends StatefulWidget {
  final Event event;
  final Function(Event) onEventUpdated;

  const DetailPageScreen({super.key, required this.event, required this.onEventUpdated});

  @override
  _DetailPageScreenState createState() => _DetailPageScreenState();
}

class _DetailPageScreenState extends State<DetailPageScreen> {
  late Event event;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  void editFun() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPage(event: event)),
    ).then((value) {
      print("object----editFun");
      setState(() {
        event = EventManager.getEventById(event.id);
      });
      widget.onEventUpdated(event);  // 通知父级更新
    });
  }
  void deleteFun() async {
    EventManager.deleteEvent(events!.id);
    Navigator.pop(context);
  }
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm the deletion'),
          content: Text('Are you sure you want to delete？'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: Text('Sure'),
              onPressed: () {
                // 执行删除操作
                deleteFun();
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }
  void saveToNextPaper() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainApp()),
            (route) => route == null);
  }

  Future<void> _captureAndShare() async {
    // 截取屏幕
    final image = await _screenshotController.capture();

    if (image != null) {
      // 保存图片到临时目录
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/screenshot.png';
      final file = File(imagePath);
      await file.writeAsBytes(image);

      // 分享图片
      await Share.shareFiles([imagePath], text: '分享的图片');
    } else {
      // 处理截屏失败的情况
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('截屏失败')),
      );
    }
  }
  void backToNextPaper() async {
    // 返回逻辑示例
    Navigator.pop(context);
  }

  void shareFun() async {
    // 分享逻辑
    _captureAndShare();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          backToNextPaper();
          return false;
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(event.bgUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 42, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          backToNextPaper();
                        },
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/img/icon_back.webp'),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          shareFun();
                        },
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/img/icon_share.webp'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          editFun();
                        },
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/img/icon_edit.webp'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          // 删除逻辑
                          showDeleteConfirmationDialog(context);
                        },
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/img/icon_delete.webp'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      width: double.infinity,
                      height: 256,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/img/bg_detile.webp'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                maxLines: 2,
                                event.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Text("Event Countdown Here"),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, right: 12, left: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddFeelPage(event: event)));
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/img/bg_fee_add.webp'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: Image.asset('assets/img/icon_feel_add.png'),
                                              ),
                                              const Text(
                                                'Add Feelings',
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FeelListPage(event: event)));
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AssetImage('assets/img/bg_fee_record.webp'),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: Image.asset('assets/img/icon_feel_re.png'),
                                              ),
                                              const SizedBox(width: 2),
                                              const Text(
                                                'Feelings Record',
                                                style: TextStyle(
                                                  color: Color(0xFF999999),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}















