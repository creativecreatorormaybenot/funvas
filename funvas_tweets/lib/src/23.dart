import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:funvas/funvas.dart';

/// Recreation of original work by Dave Whyte.
///
/// See https://twitter.com/beesandbombs/status/1376676133425590278?s=20 for
/// the inspiration.
/// All code and concepts in the code are mine - I have no idea how Dave thought
/// about this problem.
class TwentyThree extends Funvas {
  /// The total number of boxes and tiles visible on the screen when fully
  /// zoomed out.
  ///
  /// Where a box refers to a square that splits itself up into smaller tiles
  /// during the animation and a tile being the moving part.
  ///
  /// Note that these have to be odd numbers for the logic to work.
  static const _boxCount = 15, _tileCount = 9;

  /// The stable color for all tiles.
  ///
  /// There are two color modes in my take on the animation: stable and
  /// color wheel. The stable color is shown statically during some parts
  /// of the animation. In some other parts, we lerp to a color on the color
  /// wheel (to be precise, HSL colors with changing hue).
  static const _stableColor = Color(0xffe1c699);

  /// The dimension of our animation.
  ///
  /// We use the same dimension for width and height as we are aiming for a
  /// square.
  /// Side note: the 750x750 at 50 FPS practice is also inspired by Dave
  /// Whyte :)
  static const _d = 750.0;

  /// What fraction of one box one tile takes up in one dimension.
  static const _tileFraction = 1 / 3;

  /// The loop duration in seconds.
  static const _ld = 8.0;

  @override
  void u(double t) {
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);
    s2q(_d);

    // Set a nice thumbnail.
    t += 2;

    // Our center box.
    c.translate(_d / 2, _d / 2);
    c.scale(1 +
        ((_boxCount + 1) / 2) * Curves.easeInQuad.transform((t % _ld) / _ld));
    // c.rotate(-pi / 2 * ((t % _ld) / _ld));
    c.save();
    _drawBox(t, 0);
    c.restore();

    // The box extent is how many boxes we go outwards from the center.
    const boe = _boxCount ~/ 2 + 1;
    // We approach the problem in the most inefficient way, where we ignore
    // whether a box is visible on screen or not and always do all draw calls
    // that would be required if the animation was fully zoomed out.
    for (var m = 1; m < boe + 1; m++) {
      // The loop strategy is pretty obvious when you view the delay in the
      // boxes splitting up into the tiles.
      for (var i = 0; i < 4; i++) {
        c.save();
        c.rotate(i * pi / 2);
        c.translate(0, _d / 2 / boe * m);
        for (var o = 0; o <= m; o++) {
          for (var s = -1; s <= 1; s += 2) {
            c.save();
            c.translate(_d / 2 / boe * o * s, 0);
            c.rotate(-i * pi / 2);
            _drawBox(t, m * 2 - 1 + o);
            c.restore();

            // We do not need to mirror the boxes on the symmetry axes.
            if (o == 0) break;
          }
        }
        c.restore();
      }
    }
  }

  void _drawBox(double t, int delay) {
    // Turn the spiral upside down.
    c.rotate(pi);

    // I am not sure how to loop through the positions in a spiral in a good
    // way, so I am just going to do it visually on a 9x9 grid.
    var position = Point(0, 0);
    var loop = 0, i = 0;
    // The visual aspect is moving in 4 directions. I am sure doing it radially
    // would be smarter (and not doing it visually even more than that), but I
    // am having a hard time wrapping my head around that.
    var direction = 0;

    // These are the box dimensions, tile dimension, and tile dimension
    // according to the width fraction of its potential size.
    final db = _d / _boxCount;
    final dt = db / _tileCount;
    final dtf = dt * _tileFraction;

    final timePerTile = (_ld - 2) / (_tileCount + 2);
    final timeInRun = t % _ld;

    while (loop < _tileCount) {
      if (i == _tileCount * _tileCount) {
        // We have reached the center point.
        break;
      }
      i++;

      final packedOffset = Offset(
        dtf * (-_tileCount / 2 + position.x + 1 / 2),
        dtf * (-_tileCount / 2 + position.y + 1 / 2),
      );
      final spreadOffset = Offset(
        // We add -dt / 2 as a margin in order to tile the boxes seamlessly.
        // The -.42 I have no idea why. It is needed to make the zoom transition
        // seamless - seriously no clue :shrug:
        (db - dt / 2 - .42) *
            (position.x / _tileCount + 1 / _tileCount / 2 - 1 / 2),
        (db - dt / 2 - .42) *
            (position.y / _tileCount + 1 / _tileCount / 2 - 1 / 2),
      );

      final progress = min(
          1.0,
          max(0.0, timeInRun - 2 - delay / 2 - timePerTile * i / _tileCount) /
              timePerTile);
      final transformed = Curves.easeOutSine.transform(progress);

      final offset = Offset.lerp(
        packedOffset,
        spreadOffset,
        transformed,
      )!;

      c.drawRect(
        Rect.fromCenter(
          center: offset,
          width: dtf,
          height: dtf,
        ),
        Paint()
          // If we allow anti alias in the collapsed state, there are weird
          // gaps that probably also screw up the GIF export.
          ..isAntiAlias = progress == 0 ? false : true
          ..color = Color.lerp(
              _stableColor,
              HSLColor.fromAHSL(
                      1, 360 * (1 - i / _tileCount / _tileCount), .8, .7)
                  .toColor(),
              max(0, progress - timeInRun / _ld))!,
      );

      switch (direction) {
        case 0:
          if (position.x == _tileCount - 1 - loop) {
            direction = 1;
          }
          break;
        case 1:
          if (position.y == _tileCount - 1 - loop) {
            direction = 2;
          }
          break;
        case 2:
          if (position.x == loop) {
            direction = 3;
          }
          break;
        case 3:
          if (position.y == loop + 1) {
            direction = 0;
            loop++;
          }
          break;
      }
      switch (direction) {
        case 0:
          position = Point(position.x + 1, position.y);
          break;
        case 1:
          position = Point(position.x, position.y + 1);
          break;
        case 2:
          position = Point(position.x - 1, position.y);
          break;
        case 3:
          position = Point(position.x, position.y - 1);
          break;
      }
    }
  }
}
