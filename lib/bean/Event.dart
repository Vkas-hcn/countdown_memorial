import 'dart:convert';

import 'package:intl/intl.dart';

import '../utils/LocalStorage.dart';

import 'dart:convert';

class Event {
  String id;
  String name;
  String date;
  String bgUrl;
  int repeat;
  int style;
  List<Feeling> feelings;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.bgUrl,
    required this.repeat,
    required this.style,
    required this.feelings,
  });

  // 从JSON解析为Event实例
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      bgUrl: json['bgUrl'] ?? '',
      repeat: json['repeat'] ?? 0,
      style: json['style'] ?? 0,
      feelings: (json['feelings'] as List<dynamic>)
          .map((feeling) => Feeling.fromJson(feeling))
          .toList(),
    );
  }

  // 将Event实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'bgUrl': bgUrl,
      'repeat': repeat,
      'style': style,
      'feelings': feelings.map((feeling) => feeling.toJson()).toList(),
    };
  }

  // Adjust date based on repeat frequency with precision to seconds
  void adjustDateIfRepeating() {
    DateTime currentDate = DateTime.now();
    DateTime eventDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
    // Keep updating the event date to the next valid occurrence
    while (eventDate.isBefore(currentDate)) {
      switch (repeat) {
        case 1: // Every Week
          eventDate = eventDate.add(Duration(days: 7));
          break;
        case 2: // Every Month
          eventDate = DateTime(eventDate.year, eventDate.month + 1, eventDate.day, eventDate.hour, eventDate.minute, eventDate.second);
          break;
        case 3: // Every Year
          eventDate = DateTime(eventDate.year + 1, eventDate.month, eventDate.day, eventDate.hour, eventDate.minute, eventDate.second);
          break;
        default:
          break;
      }
    }
    // Update the date to the next valid occurrence
    date = DateFormat('yyyy-MM-dd HH:mm:ss').format(eventDate);
  }
}

class Feeling {
  String time;
  String message;
  int state;

  Feeling({
    required this.time,
    required this.message,
    required this.state,
  });

  // 从JSON解析为Feeling实例
  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      time: json['time'] ?? '',
      message: json['message'] ?? '',
      state: json['state'] ?? 0,
    );
  }

  // 将Feeling实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'message': message,
      'state': state,
    };
  }
}

