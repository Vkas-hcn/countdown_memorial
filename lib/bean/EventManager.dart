import 'dart:convert';

import '../utils/LocalStorage.dart';
import 'Event.dart';

class EventManager {
  static List<Event> events = [];

  // 添加一个Event到数组
  static void addEvent(Event event) {
    events.insert(0, event); // 添加到数组的第一位
    saveEvents(); // 保存到本地存储
  }

  // 保存整个事件数组到本地存储
  static Future<void> saveEvents() async {
    // 将 events 转换成 JSON 字符串
    String jsonString = json.encode(events.map((e) => e.toJson()).toList());
    await LocalStorage().setValue(LocalStorage.dateList, jsonString);
  }

  // 从本地存储读取并解析成List<Event>
  static Future<void> loadEvents2() async {
    // 从本地存储读取 JSON 字符串
    String? jsonString = await LocalStorage().getValue(LocalStorage.dateList);
    if (jsonString != null) {
      // 将 JSON 字符串解析为 List<Map<String, dynamic>>
      List<dynamic> jsonData = json.decode(jsonString);
      print("jsonString---->${jsonString}");
      //根据重复模式修改数据

      // 将每个 JSON 对象解析为 Event 实例，并添加到 events 数组
      events = jsonData.map((e) => Event.fromJson(e)).toList();
    }
  }

  static Future<void> loadEvents() async {
    // Load JSON string from local storage
    String? jsonString = await LocalStorage().getValue(LocalStorage.dateList);
    if (jsonString != null) {
      List<dynamic> jsonData = json.decode(jsonString);
      print("jsonString---->$jsonString");

      // Parse each JSON object as Event and adjust dates based on repeat
      events = jsonData.map((e) {
        Event event = Event.fromJson(e);
        //
        // // Update the date if the event is repeating and the date has passed
        // event.adjustDateIfRepeating();
        return event;
      }).toList();
    }
  }

  //获取到指定的Event
  static Event? getEventById(String eventId) {
    final foundEvents = events.where((event) => event.id == eventId).toList();
    if (foundEvents.isNotEmpty) {
      return foundEvents.first;
    } else {
      return null;
    }
  }

  // 更新指定ID的Event
  static void updateEvent(Event updatedEvent) {
    int index = events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent; // 更新事件
      saveEvents(); // 保存更改后的事件数组
    }
  }

  // 删除指定ID的Event
  static void deleteEvent(String eventId) {
    events.removeWhere((event) => event.id == eventId);
    saveEvents(); // 保存更改后的事件数组
  }
}
