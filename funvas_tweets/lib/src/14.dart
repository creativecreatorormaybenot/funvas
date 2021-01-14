import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/funvas_tweets.dart';

/// The fourteenth funvas animation for a tweet :)
///
/// Note that this is very similar to [Thirteen].
/// The reason they are similar is that I thought that the way this one turned
/// out might be a bit to crazy, so I want back with thirteen to have a simple
/// version showcasing the very details of what I imagined in my head. This one
/// shows what the you can make of the concept.
class Fourteen extends Funvas {
  @override
  void u(double t) {
    final s = s2q(750), d = s.width;

    const squareDimension = 20.0;
    const animationDuration = 10;

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
      // Draw another square (mirrored) on the other side of the track.
      c.scale(1, -1);
      drawSquare(shift);
      c.restore();
    }

    // We paint the scaffold relative to the center and go from there.
    c.translate(d / 2, d / 2);
    c.scale(1.4 + sin(pi * 2 / animationDuration * t) / 2);
    c.rotate(2 * pi / animationDuration * t -
        // I like the square coming from the top better.
        pi / 2);

    // Background
    c.drawPaint(Paint()..color = const Color(0xffffffff));
    c.drawCircle(Offset.zero, d / 2, Paint()..color = const Color(0xff000000));
    // We clip to the background circle in order to ensure that the squares are
    // not visible on the background when rolling in.
    c.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: d / 2)),
    );

    // We want to draw the tracks in a circle from start to end. There will be
    // multiple rolling squares on each track. Because we go in a whole
    const tracks = 40;
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
