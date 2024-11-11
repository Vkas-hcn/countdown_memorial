import 'dart:async';

import 'package:countdown_memorial/utils/AppUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CountdownTimer extends StatefulWidget {
  final String timestampInSeconds;

  const CountdownTimer({Key? key, required this.timestampInSeconds}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration countdownDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当时间戳改变时，重新初始化倒计时
    if (oldWidget.timestampInSeconds != widget.timestampInSeconds) {
      _initializeCountdown();
    }
  }

  void _initializeCountdown() {
    _timer?.cancel();

    int endTimeInSeconds;
    int parsedTimestamp = int.tryParse(widget.timestampInSeconds) ?? 0;
    if (parsedTimestamp > 253402300800) {
      endTimeInSeconds = parsedTimestamp ~/ 1000;
    } else {
      endTimeInSeconds = parsedTimestamp;
    }
    int currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remainingSeconds = endTimeInSeconds - currentTimeInSeconds;
    countdownDuration = Duration(seconds: remainingSeconds > 0 ? remainingSeconds : 0);
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownDuration.inSeconds > 0) {
        setState(() {
          countdownDuration -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    int days = countdownDuration.inDays;
    int hours = countdownDuration.inHours.remainder(24);
    int minutes = countdownDuration.inMinutes.remainder(60);
    int seconds = countdownDuration.inSeconds.remainder(60);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTimeWithBackground('${_formatTime(days)}', 'D'),
        _buildTimeWithBackground('${_formatTime(hours)}', 'H'),
        _buildTimeWithBackground('${_formatTime(minutes)}', 'M'),
        _buildTimeWithBackground('${_formatTime(seconds)}', 'S'),
      ],
    );
  }

  Widget _buildTimeWithBackground(String time, String unit) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: const DecorationImage(
          image: AssetImage('assets/img/bg_djs_1.webp'), // 替换为背景图片路径
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.black, // 黑色背景
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

