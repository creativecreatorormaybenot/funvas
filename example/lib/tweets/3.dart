import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

/// todo(creativecreatorormaybenot): add tweet link.
class Three extends Funvas {
  @override
  void u(double t) {
    final backgroundPaint = Paint()..color = Color(0xff0099cc),
        foregroundPaint = Paint()..color = Color(0xffcc0000);

    c.drawPaint(backgroundPaint);

    final rect = Offset.zero & Size(x.width, x.height);

    void drawBall(double radians, double distance, double radius) {
      final p = rect.center + Offset.fromDirection(radians, distance);

      c.drawLine(rect.center, p, foregroundPaint..strokeWidth = 2);
      c.drawCircle(p, radius, foregroundPaint);
    }

    drawBall(0, 42, 14);

    // Draw center dot.
    c.drawCircle(rect.center, 6, foregroundPaint);
  }
}
