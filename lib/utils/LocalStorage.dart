import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static String dateList = "dateList";
  static String bgImageList = "bgImageList";



  static String drinkingWaterNumArray = "drinkingWaterNumArray";
  static String drinkingWaterList = "drinkingWaterList";
  static String userBmiList = "userBmiList";

  static String clockData = "clockData";
  static String umpState = "umpState";

  static bool isInBack = false;
  static bool int_ad_show = false;
  static bool clone_ad = false;
  static final LocalStorage _instance = LocalStorage._internal();
  late SharedPreferences _prefs;
  static String clickFeelId = "";

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set value by key
  Future<void> setValue(String key, dynamic value) async {
    if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  // Get value by key
  dynamic getValue(String key) {
    return _prefs.get(key);
  }

}
