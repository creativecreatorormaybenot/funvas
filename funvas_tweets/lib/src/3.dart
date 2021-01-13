import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Three extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1327309901270560769?s=20';

  @override
  void u(double t) {
    final s = s2q(750), w = s.width, h = s.height;

    final backgroundPaint = Paint()..color = Color(0xffffc108),
        foregroundPaint = Paint()
          ..color = Color(0xee0175c2)
          ..strokeWidth = 2;

    c.drawPaint(backgroundPaint);

    final rect = Offset.zero & Size(w, h);

    void drawBall(double radians, double distance, double radius) {
      final p = rect.center + Offset.fromDirection(-radians - pi / 2, distance);

      c.drawLine(rect.center, p, foregroundPaint);
      c.drawCircle(p, radius, foregroundPaint);
    }

    const count = 12;

    c.translate(w / 2, h / 2);
    c.rotate(Cubic(.4, 0, .4, 1).transform(t / 10 % 1) * 2 * pi);
    c.translate(-w / 2, -h / 2);

    for (var i = 0; i < count; i++) {
      final addend = (i / count) * .5,
          curve = Cubic(.4 + addend, 0, .4 + addend, 1);
      drawBall(
        curve.transform((t - i / 12) / 2.5 % 1) * 2 * pi,
        40.0 + i * ((w / 2 - 128) / count),
        11 + i / 5,
      );
    }

    // Draw center dot.
    c.drawCircle(rect.center, 5, foregroundPaint);
  }
}
