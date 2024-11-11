import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer3 extends StatefulWidget {
  final String timestampInSeconds;

  const CountdownTimer3({Key? key, required this.timestampInSeconds}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer3> {
  late Duration countdownDuration;
   Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }
  @override
  void didUpdateWidget(covariant CountdownTimer3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timestampInSeconds != widget.timestampInSeconds) {
      _initializeCountdown();
    }
  }

  void _initializeCountdown() {
    _timer?.cancel();
    int endTimeInSeconds = int.tryParse(widget.timestampInSeconds) ?? 0;
    int currentTimeInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remainingSeconds = endTimeInSeconds - currentTimeInSeconds;
    countdownDuration = Duration(seconds: remainingSeconds > 0 ? remainingSeconds : 0);

    _startCountdown();
  }
  void _startCountdown() {
    // 每秒更新倒计时
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
    int totalSeconds = countdownDuration.inSeconds; // 获取剩余的秒数

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeWithBackground('${_formatTime(totalSeconds)}', 'Seconds'),
      ],
    );
  }

  Widget _buildTimeWithBackground(String time, String unit) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: const DecorationImage(
          image: AssetImage('assets/img/bg_djs_3.webp'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 时间部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 单位部分
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
