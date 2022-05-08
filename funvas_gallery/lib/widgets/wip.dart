import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_gallery/factories/animations.dart';

/// Displays the current [wipFunvas].
class WIPFunvasPage extends StatefulWidget {
  const WIPFunvasPage({Key? key}) : super(key: key);

  @override
  State<WIPFunvasPage> createState() => _WIPFunvasPageState();
}

class _WIPFunvasPageState extends State<WIPFunvasPage> {
  final _time = ValueNotifier(.0);

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): _ExitIntent(),
      },
      actions: {
        _ExitIntent: CallbackAction(
          onInvoke: (_) => Navigator.of(context).pop(),
        ),
      },
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: FunvasPainter(
                      time: _time,
                      delegate: wipFunvas.funvas,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: ValueListenableBuilder<double>(
                    valueListenable: _time,
                    builder: (context, value, child) {
                      return Slider(
                        min: 0,
                        max: 14.6,
                        value: value,
                        label: 'x${(pow(2, value) - 0.5).toStringAsFixed(1)}',
                        onChanged: (value) {
                          _time.value = value;
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExitIntent extends Intent {}
