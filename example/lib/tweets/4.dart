import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';

/// todo: add link.
class Four extends Funvas {
  // The movement curve should be harsher than the rotation curve because
  // the rotation should prepare for the movement.
  static const _movementCurve = Cubic(.68, .03, .31, .98),
      _rotationCurve = Cubic(.51, .15, .31, .88);

  /// Vertical and horizontal spacing.
  static const _distance = 83.3;

  /// Describes the offset that should be moved to every second.
  final _movementPath = TweenSequence<Offset>([
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
        end: Offset(_distance, 0),
      ).chain(CurveTween(curve: _movementCurve)),
      weight: 1,
    ),
    // Wait.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance, 0),
        end: Offset(_distance, 0),
      ),
      weight: 1 / 2,
    ),
    // Stay put.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance, 0),
        end: Offset(_distance, 0),
      ),
      weight: 1,
    ),
    // Move top right.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance, 0),
        end: Offset(_distance + _distance / 2, -_distance),
      ).chain(CurveTween(curve: _movementCurve)),
      weight: 1,
    ),
    // Wait.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance + _distance / 2, -_distance),
        end: Offset(_distance + _distance / 2, -_distance),
      ),
      weight: 1 / 2,
    ),
    // Stay put.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance + _distance / 2, -_distance),
        end: Offset(_distance + _distance / 2, -_distance),
      ),
      weight: 1,
    ),
    // Move left.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance + _distance / 2, -_distance),
        end: Offset(_distance / 2, -_distance),
      ).chain(CurveTween(curve: _movementCurve)),
      weight: 1,
    ),
    // Wait.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance / 2, -_distance),
        end: Offset(_distance / 2, -_distance),
      ),
      weight: 1 / 2,
    ),
    // Stay put.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance / 2, -_distance),
        end: Offset(_distance / 2, -_distance),
      ),
      weight: 1,
    ),
    // Move bottom left.
    TweenSequenceItem(
      tween: Tween(
        begin: Offset(_distance / 2, -_distance),
        end: Offset(0, 0),
      ).chain(CurveTween(curve: _movementCurve)),
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
  final _rotations = TweenSequence<double>([
    // Rotate to prepare to move right.
    TweenSequenceItem(
      tween: Tween<double>(
        begin: -1.25 * pi,
        end: 0,
      ).chain(CurveTween(curve: _rotationCurve)),
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
      ).chain(CurveTween(curve: _rotationCurve)),
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
      ).chain(CurveTween(curve: _rotationCurve)),
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
      ).chain(CurveTween(curve: _rotationCurve)),
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

  final _arrowPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(0xe5b3),
      style: const TextStyle(
        fontFamily: 'MaterialIcons',
        fontSize: 60,
        color: Color(0xffffffff),
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  @override
  void u(double t) {
    c.drawPaint(Paint()..color = Color(0xff000000));

    _arrowPainter.layout();

    void paintArrow(Offset center, double rotation) {
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(rotation);
      c.translate(-center.dx, -center.dy);

      final rect = Rect.fromCenter(
        center: center,
        width: _arrowPainter.width,
        height: _arrowPainter.height,
      );
      _arrowPainter.paint(c, rect.topLeft);

      c.restore();
    }

    const animationSeconds = pi * 2.75;

    if (t >= animationSeconds) {
      t = t % animationSeconds;
    }

    // Assuming that we wait for weight 1 / 2 seconds after every weight 2
    // seconds, we can be sure that nothing is rotating or whatever during that
    // time, which allows us to translate the canvas in order to cheat with the
    // movement :)
    final translationOffset = t < animationSeconds / 4
        ? Offset.zero
        : _movementPath.transform(
            ((t ~/ (animationSeconds / 4)) * animationSeconds / 4) /
                animationSeconds);
    c.translate(-translationOffset.dx, -translationOffset.dy);

    final center = Offset(x.width / 2, x.height / 2);

    // Delays the movements the further the arrows are away from the center.
    double outwardsDelayedT(Offset position) {
      if (center == position) return t;
      return t - (center - position).distance / 1.2e3;
    }

    Offset movementOffset(Offset position) {
      final t = max(0, outwardsDelayedT(position));
      return _movementPath.transform(t / animationSeconds);
    }

    double rotation(Offset position) {
      final t = max(0, outwardsDelayedT(position));
      return _rotations.transform(t / animationSeconds);
    }

    for (var h = 0; h < 15; h++) {
      for (var w = 0; w < 15; w++) {
        final base =
            Offset(x.width / 2 + (h.isOdd ? _distance / 2 : 0), x.height / 2);

        var preMovePosition = base + Offset(w * _distance, h * _distance);
        paintArrow(preMovePosition + movementOffset(preMovePosition),
            rotation(preMovePosition));

        preMovePosition = base + Offset(w * _distance, -h * _distance);
        paintArrow(preMovePosition + movementOffset(preMovePosition),
            rotation(preMovePosition));

        preMovePosition = base + Offset(-w * _distance, h * _distance);
        paintArrow(preMovePosition + movementOffset(preMovePosition),
            rotation(preMovePosition));

        preMovePosition = base + Offset(-w * _distance, -h * _distance);
        paintArrow(preMovePosition + movementOffset(preMovePosition),
            rotation(preMovePosition));
      }
    }
  }
}
