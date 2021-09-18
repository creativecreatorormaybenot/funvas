import 'dart:math';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

/// Animation inspired by https://www.dwitter.net/d/20460 by pavel.
///
/// The code is fully novel, only the idea is inspired by the dweet.
class Forty extends Funvas {
  static const _d = 750.0, _r = 50.0;
  static const _nl = 5, _dpl = 2;

  late final _noise = OpenSimplex2F(42);

  @override
  void u(double t) {
    s2q(_d);

    const vLim = _d + _r;
    final hLim = _d + _r * _sqrt3 / 2;

    final layers = <_Layer>[];
    for (var i = 0; i < _nl; i++) {
      final paint = Paint()
        ..color =
            i % 2 == 0 ? const Color(0xffffffff) : const Color(0xff000000);

      final layer = <_TimedRegularHexagon>[];
      var y = .0, alt = false;
      do {
        for (var x = alt ? .0 : _sqrt3 * _r / 2; x <= hLim; x += _sqrt3 * _r) {
          final time = _noise.noise3XYBeforeZ(
            x / _d * 10,
            y / _d * 10,
            i / 1,
          );
          layer.add(_TimedRegularHexagon(x, y, time, paint));
        }
        alt = !alt;
        y += _r * 3 / 2;
      } while (y <= vLim);

      layers.add(layer);
    }

    final ct = t % (_nl * _dpl);
    final n = (ct / _dpl).floor();

    final nextLayer = layers[(n + 1) % _nl];
    final currentLayer = layers[n];

    for (final hexagon in nextLayer) {
      hexagon.draw(c, _r / 2 + _r / 2 * hexagon.time);
    }
    for (final hexagon in currentLayer) {
      hexagon.draw(c, _r / 2 + _r / 2 * hexagon.time);
    }
  }
}

typedef _Layer = List<_TimedRegularHexagon>;

final _sqrt3 = sqrt(3);

class _TimedRegularHexagon {
  _TimedRegularHexagon(this.x, this.y, this.time, this.paint);

  final double x, y;
  final double time;
  final Paint paint;

  void draw(Canvas canvas, double radius) {
    if (radius == 0) return;
    assert(radius > 0);

    final points = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final angle = pi / 3 * i + pi / 2;

      points.add(Offset(
        x + radius * cos(angle),
        y + radius * sin(angle),
      ));
    }
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }
}
