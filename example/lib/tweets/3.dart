import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

/// todo(creativecreatorormaybenot): add tweet link.
class Three extends Funvas {
  @override
  void u(double t) {
    final backgroundPaint = Paint()..color = Color(0xff600060),
        foregroundPaint = Paint()..color = Color(0xeeadffd2);

    c.drawPaint(backgroundPaint);

    final rect = Offset.zero & Size(x.width, x.height);

    void drawBall(double radians, double distance, double radius) {
      final p = rect.center + Offset.fromDirection(-radians - pi / 2, distance);

      c.drawLine(rect.center, p, foregroundPaint..strokeWidth = 1);
      c.drawCircle(p, radius, foregroundPaint);
    }

    const count = 12;

    c.translate(x.width / 2, x.height / 2);
    c.rotate(Cubic(.4, 0, .4, 1).transform(t / 10 % 1) * 2 * pi);
    c.translate(-x.width / 2, -x.height / 2);

    for (var i = 0; i < count; i++) {
      final addend = (i / count) * .5,
          curve = Cubic(.4 + addend, 0, .4 + addend, 1);
      drawBall(
        curve.transform((t - i / 12) / 2.5 % 1) * 2 * pi,
        40.0 + i * ((x.width / 2 - 56) / count),
        9 + i / 6,
      );
    }

    // Draw center dot.
    c.drawCircle(rect.center, 5, foregroundPaint);
  }
}
