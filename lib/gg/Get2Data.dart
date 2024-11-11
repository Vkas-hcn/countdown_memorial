import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../utils/LocalStorage.dart';
import 'package:http/http.dart' as http;

class Get2Data with ChangeNotifier {
  static const String BLACK_URL =
      "https://cap.healthkeeperhydration.com/umber/law/cribbage";
  static String fqaId = "";

  static String getUUID() {
    var uuid = Uuid();
    return uuid.v4();
  }

  static void initializeFqaId() {
    if (fqaId.isEmpty) {
      fqaId = getUUID();
    }
  }

  Future<void> getBlackList(BuildContext context) async {
    String? data = LocalStorage().getValue(LocalStorage.clockData);
    print("Blacklist data=${data}");

    if (data != null) {
      return;
    }
    final mapData = await cloakMapData(context);
    try {
      final response = await getMapData(BLACK_URL, mapData);
      LocalStorage().setValue(LocalStorage.clockData,response);
      notifyListeners();
    } catch (error) {
      retry(context);
    }
  }


  Future<Map<String, dynamic>> cloakMapData(BuildContext context) async {
    return {
      "fusty": "com.daily.waterreminder.healthylife",
      "afford": "quagmire",
      "toefl": await getAppVersion(context),
      "perseid": fqaId,
      "brink": DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<String> getAppVersion(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getMapData(String url, Map<String, dynamic> map) async {
    print("开始请求---${map}");
    final queryParameters = map.entries
        .map((entry) =>
    '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    final urlString =
    url.contains("?") ? "$url&$queryParameters" : "$url?$queryParameters";
    final response = await http.get(Uri.parse(urlString));

    if (response.statusCode == 200) {
      print("请求结果：${response.body}");
      return response.body;
    } else {
      print("请求出错：HTTP error: ${response.statusCode}");

      throw HttpException('HTTP error: ${response.statusCode}');
    }
  }

  void retry(BuildContext context) async {
    await Future.delayed(Duration(seconds: 10));
    await getBlackList(context);
  }
}
