import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';

class ThirtyTwo extends Funvas {
  @override
  void u(double t) {
    final h = s2q(750).width / 2;
    c.drawColor(const Color(0xFF303030), BlendMode.srcOver);
    c.translate(h, h);
    int i, j, s;
    for (i = 9; i > 0; i--) {
      // The piece of code responsible for the angle is inspired by
      // https://www.dwitter.net/d/20577, which was created by pavel.
      // That animation is inspired by Dave Whyte (beesandbombs).
      for (j = s = 3 << (i ~/ 3) + 1; j > 0; j--) {
        final af = s / (j + i / (1 + pow(4, 4 + i - t % 4.5 * 4)));
        final p = Offset.fromDirection(2 * pi / af - pi / 2, i * 37);
        final co = HSLColor.fromAHSL(1, (-360 / af - 42) % 360, 1, 3 / 4);
        c.drawCircle(p, 11 - i / 1.5, Paint()..color = co.toColor());
      }
    }
  }
}
