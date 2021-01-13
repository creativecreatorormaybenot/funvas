import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';

class Twelve extends Funvas {
  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;

    // Background
    c.drawPaint(Paint()..color = const Color(0xffffffff));

    const sideLength = 50.0;

    // Draws a square of squares at the current canvas center that is 100x100.
    void drawSS(double t, Color color) {
      // Cannot quickly find a formula for making the correct rect spin, so
      // I will just quickly hard code all the cases.
      final spinAddend = Curves.linearToEaseOut.transform(t % 1) * pi / 2;
      final rectSpins = <int, List<double>>{
        0: [0, 0, spinAddend],
        1: [0, spinAddend, pi / 2],
        2: [spinAddend, pi / 2, pi / 2],
        3: [pi / 2, pi / 2, pi / 2 + spinAddend],
      };
      final currentSpins = rectSpins[(t % rectSpins.length).floor()]!;
      for (var i = 0; i < 3; i++) {
        final spin = currentSpins[i];

        c.save();
        c.rotate(pi / 2 * i + spin);
        c.drawRect(
          Offset.zero & Size(sideLength, sideLength),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        );
        c.restore();
      }
    }

    for (var i = 0.0; i < w; i += sideLength * 3) {
      for (var j = 0.0; j < h; j += sideLength * 3) {
        c.save();
        c.translate(i + sideLength * 1.5, j + sideLength * 1.5);
        drawSS(
          t - i / sideLength - j / sideLength,
          HSVColor.fromAHSV(
            1,
            i / w * 180 + j / h * 180,
            1,
            .76,
          ).toColor(),
        );
        c.restore();
      }
    }
  }
}
