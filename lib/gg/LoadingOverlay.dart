import 'package:flutter/material.dart';

class LoadingOverlay {
  static final LoadingOverlay _singleton = LoadingOverlay._internal();

  factory LoadingOverlay() {
    return _singleton;
  }

  LoadingOverlay._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 半透明的遮罩层
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ad loading',
                    style: TextStyle(
                      color: Colors.white, fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
