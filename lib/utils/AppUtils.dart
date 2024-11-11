import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../bean/EventManager.dart';
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

  static Image getImagePath(String name) {
    return name.startsWith('/data')
        ? Image.file(
            File(name),
            fit: BoxFit.cover,
          )
        : Image.asset(
            name,
            fit: BoxFit.cover,
          );
  }

  // 自定义方法 _getImageProvider
  static ImageProvider getImageProvider(String bgUrl) {
    if (bgUrl.startsWith('assets/')) {
      // 如果路径以 'assets/' 开头，则加载应用内部资源图片
      return AssetImage(bgUrl);
    } else {
      // 否则，加载手机相册中的图片
      return FileImage(File(bgUrl));
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
}