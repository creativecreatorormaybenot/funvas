import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

/// todo: add link.
class Five extends Funvas {
  @override
  void u(double t) {
    c.drawPaint(Paint()..color = Color(0xffffffff));

    for (var A = .0, q = 123, j = .0, i = 756;
        i-- > 0;
        c.drawRect(
      Rect.fromLTWH(
          x.width / 2 + A * sin(j), x.height / 2 + A * cos(j), i / 84, i / 84),
      Paint()..color = Color.fromRGBO(i % 99 + 156, q - i % q, q, 1),
    )) {
      j = i / 9;
      A = (9 * sin(t * j / 20) + cos(20 * j) + 6) * 21;
    }
  }
}
