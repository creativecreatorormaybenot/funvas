import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/34.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

/// Based on [ThirtyFour] with some slight adjustments.
class ThirtyFive extends Funvas with FunvasTweetMixin {
  @override
  String get tweet => 'https://twitter.com/creativemaybeno';

  /// Base precision for the paths being drawn.
  ///
  /// A value of `2` will result in twice as many path segments per circle
  /// as `1`.
  static const _precision = 250;

  /// Disturbance for the roundness of the circles drawn (= how much the noise
  /// distorts the circle paths).
  static const _disturbance = 424.24;

  /// How much the circles should be distorted over time.
  ///
  /// This is similar to [_disturbance] but only affects the relative speed of
  /// the distortions, where bigger is faster.
  static const _wobbliness = 1 / 4;

  /// How many times a circle should reappear (from the center) within the
  /// [_period].
  ///
  /// The larger the faster the circles grow.
  static const _revolutions = 2;

  static const _dimension = 750.0, _period = 7, _n = 30, _seed = 42;

  final _noise = OpenSimplex2S(_seed);

  @override
  void u(double t) {
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
    final s = s2q(_dimension);
    c.translate(s.width / 2, s.height / 2);
    c.scale(2 + sin(t * 2 * pi / _period));
    for (var i = 0; i < _n; i++) {
      _drawStep(i, t);
    }
  }

  void _drawStep(int i, double t) {
    const di = sqrt2 * _dimension / 1.5;
    const dr = di / _n;
    const tsr = _period / (_revolutions * _n);
    final ts = ((t - tsr * i) % (_period / _revolutions)) / tsr * dr;
    final ta = t * 2 * pi / _period;
    final so = Offset(i * 20, i * 42);
    _drawCircle(ta, di - ts, so);
  }

  void _drawCircle(double ta, double r, Offset so) {
    const to = 0.7;
    final precision = 2 * pi / _precision;
    final tx = sin(ta) * _wobbliness, ty = cos(ta) * _wobbliness;

    final path = Path();
    for (var a = 0.0; a < 2 * pi; a += precision) {
      final dx = sin(a), dy = cos(a);
      final nr = r +
          _noise.noise4XYBeforeZW(dx + so.dx, dy + so.dy, tx, ty) *
              _disturbance *
              r /
              sqrt2 /
              _dimension;
      final x = dx * nr, y = dy * nr;
      if (a == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final o = (to * r / _dimension * sqrt2 * 8).clamp(0.0, to);
    c.drawPath(
      path..close(),
      Paint()
        ..color = const Color(0xffffffff).withOpacity(o)
        ..strokeWidth = 4.2
        ..style = PaintingStyle.stroke,
    );
  }
}
