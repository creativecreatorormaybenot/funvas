import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';

/// https://twitter.com/creativemaybeno/status/1326274769227046913?s=20
class Two extends Funvas {
  @override
  void u(double t) {
    // Black background (white square outlines).
    final backgroundPaint = Paint()..color = const Color(0xff000000),
        outlinePaint = Paint()
          ..color = const Color(0xffffffff)
          ..style = PaintingStyle.stroke;

    c.drawPaint(backgroundPaint);

    const startStroke = 5,
        endStroke = 0,
        startRadius = 19,
        endRadius = 1,
        padding = 16;
    final startPosition = Offset(startRadius / 2 + startStroke + padding,
            startRadius / 2 + startStroke + padding),
        endPosition = Offset(x.width / 2, x.height / 2);

    // Draws a single square outline sequence from outside to inside.
    void sequence(double progress) {
      c.drawRect(
          Rect.fromCircle(
              center: Offset.lerp(startPosition, endPosition, progress),
              radius: lerpDouble(startRadius, endRadius, progress)),
          outlinePaint
            ..strokeWidth = lerpDouble(startStroke, endStroke, progress));
    }

    void centerRotation(double radians) {
      c.translate(x.width / 2, x.height / 2);
      c.rotate(radians);
      c.translate(-x.width / 2, -x.height / 2);
    }

    centerRotation(t);

    for (var i = 0; i < 5; i++) {
      final d = t + i / 10;

      sequence(S(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 2);
      sequence(S(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
    }

    centerRotation(t * 1.1);

    for (var i = 0; i < 5; i++) {
      final d = t + i / 10 + pi / 3;

      sequence(S(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 2);
      sequence(S(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
      centerRotation(pi / 4);
      sequence(C(d).abs());
    }
  }
}
