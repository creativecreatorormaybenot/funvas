import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Thirteen extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1350085831550148611?s=20';

  @override
  void u(double t) {
    final s = s2q(750), d = s.width;

    const squareDimension = 24.0;
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
          Offset.zero & const Size.square(squareDimension),
          const Radius.circular(4),
        ),
        Paint()
          ..color = const Color(0xffffffff)
          ..blendMode = BlendMode.difference,
      );
      c.restore();
    }

    void drawTrack() {
      c.drawLine(
        const Offset(0, 0),
        Offset(d, 0),
        Paint()
          ..color = const Color(0xaaffffff)
          ..strokeWidth = 2,
      );
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
    // multiple rolling squares on each track because we go in a whole circle.
    const tracks = 8;
    for (var i = 0; i < tracks; i++) {
      c.save();
      c.rotate(pi * 2 / tracks * i);
      c.translate(-d / 2, 0);

      final shift = animationDuration / tracks / 2 * i;
      drawSquare(shift);
      // Can mirror the square here to the other side of the track when there
      // is enough space.
      // c.scale(1, -1);
      // drawSquare(shift);
      // This also creates a mirror in some way, just one going in the other
      // direction because we draw every track twice (when we go in a full
      // circle, we will draw them once from each direction).
      drawSquare(animationDuration / 2 + shift);
      c.restore();
    }
    // Draw the tracks above the squares. This will make them appear below the
    // squares because the squares use a difference blend mode.
    for (var i = 0; i < tracks; i++) {
      c.save();
      c.rotate(pi * 2 / tracks * i);
      drawTrack();
      c.restore();
    }
  }
}
