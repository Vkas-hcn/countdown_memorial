import 'dart:io';
import 'package:countdown_memorial/AddDate.dart';
import 'package:countdown_memorial/EditPage.dart';
import 'package:countdown_memorial/FeelListPage.dart';
import 'package:countdown_memorial/MainApp.dart';
import 'package:countdown_memorial/bean/EventManager.dart';
import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:countdown_memorial/utils/LocalStorage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'AddFeelPage.dart';
import 'ad/LoadingOverlay.dart';
import 'ad/ShowAdFun.dart';
import 'bean/Event.dart';

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

  const DetailPageScreen(
      {super.key, required this.event, required this.onEventUpdated});

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
      setState(() {
        event = EventManager.getEventById(event.id)!;
      });
      print("object----editFun=${event.toJson()}");

      widget.onEventUpdated(event); // 通知父级更新
    });
  }

  void deleteFun() async {
    EventManager.deleteEvent(event.id);
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
    Navigator.pop(context);
  }

  void shareFun() async {
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
        child: FutureBuilder<ImageProvider>(
          future: AppUtils.getImageProvider(event.bgUrl),
          builder: (context, snapshot) {
            return Container(
              height: double.infinity,
              decoration: BoxDecoration(
                image: snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? DecorationImage(
                        image: snapshot.data!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 42, left: 20, right: 20),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    maxLines: 2,
                                    event.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, right: 12, left: 12),
                                  child: AppUtils.getCountDownWidget(
                                      widget.event.style, widget.event.date),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, right: 12, left: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddFeelPage(
                                                          event: event)));
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/img/bg_fee_add.webp'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 24),
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: Image.asset(
                                                        'assets/img/icon_feel_add.png'),
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
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FeelListPage(
                                                            event: event)));
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/img/bg_fee_record.webp'),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 24),
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: Image.asset(
                                                        'assets/img/icon_feel_re.png'),
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
            );
          },
        ),
      ),
    );
  }
}
