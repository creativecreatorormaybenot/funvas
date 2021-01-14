import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';

class Thirteen extends Funvas {
  @override
  void u(double t) {
    final s = s2q(750), d = s.width;

    const squareDimension = 16.0;
    const animationDuration = 8;
    const scale = 1.5;

    void drawSquare(double shift) {
      c.save();
      final progress = (t + shift) %
          animationDuration *
          // Make the squares cross the track exactly once (+ an extra width to
          // make the entrance seamless) in the given duration.
          ((d / squareDimension + 1) / animationDuration);
      c.translate(progress.floor() * squareDimension, 0);
      c.rotate(-pi / 2 * (progress % 1));
      c.translate(-squareDimension, 0);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & Size.square(squareDimension),
          Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xffffffff)
          ..blendMode = BlendMode.difference,
      );
      c.restore();
    }

    void drawTrack(double shift) {
      c.save();
      c.drawLine(
        Offset(0, 0),
        Offset(d, 0),
        Paint()..color = const Color(0x66ffffff),
      );

      drawSquare(shift);
      c.restore();
    }

    // We paint the scaffold relative to the center and go from there.
    c.translate(d / 2, d / 2);
    c.scale(scale);
    c.rotate(2 * pi / animationDuration * t);

    // Background
    c.drawPaint(Paint()..color = const Color(0xffffffff));
    // The circle is technically redundant when using scale >= 1.5 :)
    c.drawCircle(Offset.zero, d / 2, Paint()..color = const Color(0xff000000));
    // We clip to the background circle in order to ensure that the squares are
    // not visible on the background when rolling in.
    c.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: d / 2)),
    );

    // We want to draw the tracks in a circle from start to end. There will be
    // multiple rolling squares on each track. Because we go in a whole
    const tracks = 42;
    for (var i = 0; i < tracks; i++) {
      c.save();
      c.rotate(pi * 2 / tracks * i);
      c.translate(-d / 2, 0);

      final shift = animationDuration / tracks / 2 * i;
      drawTrack(shift);
      drawTrack(animationDuration / 2 + shift);
      c.restore();
    }
  }
}
