import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';

/// todo: add link.
class Four extends Funvas {
  @override
  void u(double t) {
    // The movement curve should be harsher than the rotation curve because
    // the rotation should prepare for the movement.
    const movementCurve = Cubic(.68, .03, .31, .98),
        rotationCurve = Cubic(.51, .15, .31, .88);

    final backgroundPaint = Paint()..color = Color(0xff000000),
        foregroundPaint = Paint()..color = Color(0xffffffff);

    c.drawPaint(backgroundPaint);

    // The distance is (obviously) used both for spacing and movement distance
    // because we want to create a perfect loop, which requires the movement
    // of one arrow to end up at the location of another arrow. Hence, the
    // spacing needs to equal the movement distance.
    const distance = 42.0;

    final arrowPainter = TextPainter(
      text: const TextSpan(
        text: '→',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    arrowPainter.layout();

    void paintArrow(
        Offset center,
        // The rotation progress between 0 and 1.
        double rotation) {
      c.save();
      c.translate(x.width / 2, x.height / 2);
      c.rotate(rotation * pi * 2);
      c.translate(-x.width / 2, -x.height / 2);

      final rect = Rect.fromCenter(
        center: center,
        width: arrowPainter.width,
        height: arrowPainter.height,
      );
      arrowPainter.paint(c, rect.topLeft);

      c.restore();
    }

    paintArrow((Offset.zero & Size(x.width, x.height)).center,
        rotationCurve.transform(t % 1));
    paintArrow(
        (Offset.zero & Size(x.width, x.height)).center +
            Offset.fromDirection(pi / 4, distance),
        rotationCurve.transform((t + .1) % 1));
  }
}
