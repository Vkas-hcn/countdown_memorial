import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountdownTimer2 extends StatefulWidget {
  final String timestampInSeconds;

  const CountdownTimer2({Key? key, required this.timestampInSeconds})
      : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer2> {
  late Duration countdownDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void didUpdateWidget(covariant CountdownTimer2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当时间戳改变时，重新初始化倒计时
    if (oldWidget.timestampInSeconds != widget.timestampInSeconds) {
      _initializeCountdown();
    }
  }

  void _initializeCountdown() {
    _timer?.cancel();
    int endTimeInSeconds = int.tryParse(widget.timestampInSeconds) ?? 0;
    int currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remainingSeconds = endTimeInSeconds - currentTimeInSeconds;
    countdownDuration =
        Duration(seconds: remainingSeconds > 0 ? remainingSeconds : 0);
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
        _buildTimeWithBackground('${_formatTime(days)}', 'Days'),
        _buildTimeWithBackground('${_formatTime(hours)}', 'Hours'),
        _buildTimeWithBackground('${_formatTime(minutes)}', 'Minutes'),
        _buildTimeWithBackground('${_formatTime(seconds)}', 'Seconds'),
      ],
    );
  }

  Widget _buildTimeWithBackground(String time, String unit) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: const DecorationImage(
          image: AssetImage('assets/img/bg_djs_2.webp'), // 替换为背景图片路径
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 时间部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 单位部分
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.black, // 黑色背景
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unit,
              style: const TextStyle(
                fontSize: 10,
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
