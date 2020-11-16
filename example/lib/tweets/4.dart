import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
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

    const distance = 83.3;

    final arrowPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(0xe5b3),
        style: const TextStyle(
          fontFamily: 'MaterialIcons',
          fontSize: 69,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    arrowPainter.layout();

    void paintArrow(Offset center, double rotation) {
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(rotation);
      c.translate(-center.dx, -center.dy);

      final rect = Rect.fromCenter(
        center: center,
        width: arrowPainter.width,
        height: arrowPainter.height,
      );
      arrowPainter.paint(c, rect.topLeft);

      c.restore();
    }

    // Describes the offset that should be moved to every second.
    final movementPath = TweenSequence<Offset>([
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: Offset.zero,
        ),
        weight: 1,
      ),
      // Move right.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: Offset(distance, 0),
        ).chain(CurveTween(curve: movementCurve)),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance, 0),
          end: Offset(distance, 0),
        ),
        weight: 1 / 2,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance, 0),
          end: Offset(distance, 0),
        ),
        weight: 1,
      ),
      // Move top right.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance, 0),
          end: Offset(distance + distance / 2, -distance),
        ).chain(CurveTween(curve: movementCurve)),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance + distance / 2, -distance),
          end: Offset(distance + distance / 2, -distance),
        ),
        weight: 1 / 2,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance + distance / 2, -distance),
          end: Offset(distance + distance / 2, -distance),
        ),
        weight: 1,
      ),
      // Move left.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance + distance / 2, -distance),
          end: Offset(distance / 2, -distance),
        ).chain(CurveTween(curve: movementCurve)),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance / 2, -distance),
          end: Offset(distance / 2, -distance),
        ),
        weight: 1 / 2,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance / 2, -distance),
          end: Offset(distance / 2, -distance),
        ),
        weight: 1,
      ),
      // Move bottom left.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(distance / 2, -distance),
          end: Offset(0, 0),
        ).chain(CurveTween(curve: movementCurve)),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(0, 0),
          end: Offset(0, 0),
        ),
        weight: 1 / 2,
      ),
    ]);

    // The wait sections are shared. The stay put sections are reversed
    // compared to the movement.
    final rotations = TweenSequence<double>([
      // Rotate to prepare to move right.
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -1.25 * pi,
          end: 0,
        ).chain(CurveTween(curve: rotationCurve)),
        weight: 1,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0,
        ),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 0,
        ),
        weight: 1 / 2,
      ),
      // Rotate to prepare moving top right.
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.75 * pi,
        ).chain(CurveTween(curve: rotationCurve)),
        weight: 1,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: 1.75 * pi,
          end: 1.75 * pi,
        ),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: 1.75 * pi,
          end: 1.75 * pi,
        ),
        weight: 1 / 2,
      ),
      // Rotate to prepare moving left.
      TweenSequenceItem(
        tween: Tween(
          begin: 1.75 * pi,
          end: 3 * pi,
        ).chain(CurveTween(curve: rotationCurve)),
        weight: 1,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: 3 * pi,
          end: 3 * pi,
        ),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: 3 * pi,
          end: 3 * pi,
        ),
        weight: 1 / 2,
      ),
      // Rotate to prepare moving bottom left.
      TweenSequenceItem(
        tween: Tween(
          begin: 3 * pi,
          end: 4.75 * pi,
        ).chain(CurveTween(curve: rotationCurve)),
        weight: 1,
      ),
      // Stay put.
      TweenSequenceItem(
        tween: Tween(
          begin: 4.75 * pi,
          end: 4.75 * pi,
        ),
        weight: 1,
      ),
      // Wait.
      TweenSequenceItem(
        tween: Tween(
          begin: 4.75 * pi,
          end: 4.75 * pi,
        ),
        weight: 1 / 2,
      ),
    ]);

    const animationSeconds = 10;

    if (t >= animationSeconds) {
      t = t % animationSeconds;
    }

    // Assuming that we wait for 0.5 seconds after every 2 seconds, we can be
    // sure that nothing is rotating or whatever during that time, which allows
    // us to translate the canvas in order to cheat with the movement :)
    final translationOffset = t < 2.5
        ? Offset.zero
        : movementPath.transform(((t ~/ 2.5) * 2.5) / animationSeconds);
    c.translate(-translationOffset.dx, -translationOffset.dy);

    // Delays the movements the further the arrows are away from the center.
    double outwardsDelayedT(int w, int h) {
      return t - (w.abs() + h.abs()) / 22;
    }

    Offset movementOffset(int w, int h) {
      final t = max(0, outwardsDelayedT(w, h));
      return movementPath.transform(t / animationSeconds);
    }

    double rotation(int w, int h) {
      final t = max(0, outwardsDelayedT(w, h));
      return rotations.transform(t / animationSeconds);
    }

    for (var h = 0; h < 15; h++) {
      for (var w = 0; w < 15; w++) {
        final base = (Offset.zero & Size(x.width, x.height)).center +
            Offset(h.isOdd ? distance / 2 : 0, 0) +
            movementOffset(w, h);
        final radians = rotation(w, h);

        paintArrow(base + Offset(w * distance, h * distance), radians);
        paintArrow(base + Offset(w * distance, -h * distance), radians);
        paintArrow(base + Offset(-w * distance, h * distance), radians);
        paintArrow(base + Offset(-w * distance, -h * distance), radians);
      }
    }
  }
}
