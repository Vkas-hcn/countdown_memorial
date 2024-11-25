import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../ad/ShowAdFun.dart';
import '../we/CountdownTimer.dart';
import '../we/CountdownTimer2.dart';
import '../we/CountdownTimer3.dart';
import 'LocalStorage.dart';

class AppUtils {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    final number = num.tryParse(s);
    return number != null;
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static String getNowDate() {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static List<String> getBgImageView() {
    String? stringValue =
        LocalStorage().getValue(LocalStorage.bgImageList) as String?;
    if (stringValue != null && stringValue.isNotEmpty) {
      try {
        images = List<String>.from(json.decode(stringValue));
      } catch (e) {
        print('Error decoding images from storage: $e');
      }
    }
    return images;
  }

  static void addImageToTop(String imagePath) {
    images.insert(0, imagePath);
    _saveImagesToStorage();
  }

  static void _saveImagesToStorage() {
    String jsonImages = json.encode(images);
    LocalStorage().setValue(LocalStorage.bgImageList, jsonImages);
  }

  static String timestampToYMD(String timestampInSeconds) {
    int timestamp = int.parse(timestampInSeconds);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String getFormattedDate(String? selectedDate) {
    if (selectedDate != null) {
      try {
        DateTime dateTime = DateFormat('yyyy/MM/dd').parse(selectedDate);
        return DateFormat('yyyy/MM/dd').format(dateTime);
      } catch (e) {
        return 'Invalid date format';
      }
    } else {
      return 'No date selected';
    }
  }

  static String getTimeFromTimestamp(String timestampInSeconds) {
    int timestamp = int.parse(timestampInSeconds);
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

// 获取持久化路径
  static Future<String> getPersistentImagePath(String originalPath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = originalPath.split('/').last; // 获取文件名
    final String newPath = '${appDocDir.path}/$fileName';
    return newPath;
  }

// 将图片保存到持久化存储
  static Future<String> saveImageToPersistentStorage(
      String originalPath) async {
    final File originalFile = File(originalPath);
    final String newPath = await getPersistentImagePath(originalPath);
    final File persistentFile = File(newPath);

    // 如果文件在持久路径中不存在，则复制过去
    if (!await persistentFile.exists()) {
      await originalFile.copy(newPath);
    }
    return newPath; // 返回持久化路径
  }

// 加载图片的方法
  static Future<ImageProvider> getImageProvider(String bgUrl) async {
    if (bgUrl.startsWith('assets/')) {
      return AssetImage(bgUrl);
    } else {
      final String persistentPath = await getPersistentImagePath(bgUrl);
      return FileImage(File(persistentPath));
    }
  }


  static Future<Image> getImagePath(String name) async {
    if (name.startsWith('assets/')) {
      return Image.asset(
        name,
        fit: BoxFit.cover,
      );
    } else {
      final String persistentPath = await getPersistentImagePath(name);
      return Image.file(
        File(persistentPath),
        fit: BoxFit.cover,
      );
    }
  }


  //返回倒计时组件
  static Widget getCountDownWidget(int slete, String time) {
    if (slete == 1) {
      return CountdownTimer(timestampInSeconds: time);
    }
    if (slete == 2) {
      return CountdownTimer2(timestampInSeconds: time);
    }
    if (slete == 3) {
      return CountdownTimer3(timestampInSeconds: time);
    }
    return CountdownTimer(timestampInSeconds: time);
  }

  static List<String> getOptionsData() {
    return options;
  }
  static ShowAdFun getMobUtils(BuildContext context) {
    final adManager = ShowAdFun(context);
    return adManager;
  }

  static Future<void> showScanAd(
      BuildContext context,
      AdWhere adPosition,
      int moreTime,
      Function() loadingFun,
      Function() nextFun,
      ) async {
    final Completer<void> completer = Completer<void>();
    var isCancelled = false;

    void cancel() {
      isCancelled = true;
      completer.complete();
    }

    Future<void> _checkAndShowAd() async {
      bool colckState = await ShowAdFun.blacklistBlocking();
      if (colckState) {
        nextFun();
        return;
      }
      if (!getMobUtils(context).canShowAd(adPosition)) {
        getMobUtils(context).loadAd(adPosition);
      }

      if (getMobUtils(context).canShowAd(adPosition)) {
        loadingFun();
        getMobUtils(context).showAd(context, adPosition, nextFun);
        return;
      }
      if (!isCancelled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _checkAndShowAd();
      }
    }

    Future.delayed( Duration(seconds: moreTime), cancel);
    await Future.any([
      _checkAndShowAd(),
      completer.future,
    ]);

    if (!completer.isCompleted) {
      return;
    }
    print("插屏广告展示超时");
    nextFun();
  }
  // 本地图片数组
  static List<String> images = [
    'assets/img/bg_1.webp',
    'assets/img/bg_2.webp',
    'assets/img/bg_3.webp',
    'assets/img/bg_4.webp',
    'assets/img/bg_5.webp',
    'assets/img/bg_6.webp',
    'assets/img/bg_7.webp',
    'assets/img/bg_8.webp',
  ];

  static List<String> options = [
    "Does Not Repeat",
    "Every Week",
    "Every Month",
    "Every Year",
  ];

  static String getSelectCountName(int state) {
    switch (state) {
      case 1:
        return 'assets/img/icon_happy.webp';
      case 2:
        return 'assets/img/icon_neutral.webp';
      case 3:
        return 'assets/img/icon_unhappy.webp';
      default:
        return 'assets/img/icon_happy.webp';
    }
  }

  static String getBgFeelName(int state) {
    switch (state) {
      case 1:
        return 'assets/img/bg_record_1.webp';
      case 2:
        return 'assets/img/bg_record_2.webp';
      case 3:
        return 'assets/img/bg_record_3.webp';
      default:
        return 'assets/img/bg_record_1.webp';
    }
  }

  static String getMoodName(int state) {
    switch (state) {
      case 1:
        return 'Mood: Happy';
      case 2:
        return 'Mood: Neutral';
      case 3:
        return 'Mood: Unhappy';
      default:
        return 'Mood: Happy';
    }
  }
}
