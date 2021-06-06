import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

class TwentySix extends Funvas {
  static const _n = 2560;

  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    c.translate(d / 2, d / 2);

    drawFrame(t, d, 1);
  }

  void drawFrame(double t, double d, double alpha) {
    for (var i = 0; i < _n; i++) {
      c.drawCircle(
        Offset(
              cos(pi * t + 2 * pi / _n * i),
              cos(i / _n * pi / 2 + pi * t + 2 * pi / _n * i),
            ) *
            (d / 3),
        10,
        Paint()
          ..color = HSVColor.fromAHSV(
            alpha,
            360 / _n * i,
            3 / 4,
            3 / 4,
          ).toColor(),
      );
    }
  }
}
