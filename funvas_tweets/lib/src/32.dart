import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

class ThirtyTwo extends Funvas {
  @override
  void u(double t) {
    final d = s2q(750).width;
    c.drawColor(const Color(0xFF303030), BlendMode.srcOver);
    c.translate(d / 2, d / 2);

    final p = Path();
    for (var i = 9; i > 0; i--) {
      // The piece of code responsible for the angle is inspired by
      // https://www.dwitter.net/d/20577, which was created by pavel.
      // That animation is inspired by Dave Whyte (beesandbombs).
      var s = 3 << (i ~/ 3) + 1;
      for (var j = s; j > 0; j--) {
        final af = s / (j + i / (1 + pow(4, 4 + i - t % 4.5 * 4)));
        p.lineTo(
            Offset.fromDirection(
              2 * pi / af - pi / 2,
              i * 37,
            ).dx,
            Offset.fromDirection(
              2 * pi / af - pi / 2,
              i * 37,
            ).dy);
        c.drawCircle(
          Offset.fromDirection(
            2 * pi / af - pi / 2,
            i * 37,
          ),
          11 - i / 1.5,
          Paint()
            ..color = HSLColor.fromAHSL(
              1,
              (-360 / af - 42) % 360,
              1,
              3 / 4,
            ).toColor(),
        );
      }
    }
    c.drawPath(
        p,
        Paint()
          ..color = const Color(0xffffffff)
          ..style = PaintingStyle.stroke);
  }
}
