import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

class Eleven extends Funvas {
  @override
  void u(double t) {
    final scaling = min(x.width, x.height) / 750;
    final w = x.width / scaling, h = x.height / scaling;
    c.scale(scaling);

    c.drawPaint(Paint()..color = const Color(0xfffaddaa));

    const foregroundColor = Color(0xffff6a50);
    c.translate(w / 2, h / 2);
    c.drawCircle(Offset.zero, 76, Paint()..color = foregroundColor);

    const outerRadius = 108.0, step = 40, orbits = 7;
    for (var i = orbits - 1; i >= 0; i--) {
      final radius = outerRadius + step * i;

      c.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = foregroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      c.save();
      c.rotate(sin((t + i * 2) / 2) * 2 * pi);
      c.drawCircle(
        Offset.fromDirection(-pi / 2, radius),
        11,
        Paint()..color = foregroundColor,
      );
      c.restore();
    }
  }
}
