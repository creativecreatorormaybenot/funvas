import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

/// Animation inspired by https://www.dwitter.net/d/20460 by pavel.
///
/// The code is fully novel, only the idea is inspired by the dweet.
class Forty extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1439265804709679111?s=20';

  static const _d = 750.0, _r = 50.0;
  static const _nl = 6, _dpl = 3;
  static const _curve = Curves.fastOutSlowIn;

  late final _noise = OpenSimplex2F(42);
  final _layers = <_Layer>[];

  @override
  void u(double t) {
    s2q(_d);

    const vLim = _d + _r;
    final hLim = _d + _r * _sqrt3 / 2;

    if (_layers.isEmpty) {
      for (var i = 0; i < _nl; i++) {
        final color =
            i % 2 == 0 ? const Color(0xffffffff) : const Color(0xff000000);

        final layer = <_TimedRegularHexagon>[];
        var y = .0, alt = false;
        do {
          for (var x = alt ? .0 : _sqrt3 * _r / 2;
              x <= hLim;
              x += _sqrt3 * _r) {
            final time = _noise.noise3XYBeforeZ(
              x / _d * 10,
              y / _d * 10,
              i / 1,
            );
            layer.add(_TimedRegularHexagon(x, y, (time - 1) / 2, color));
          }
          alt = !alt;
          y += _r * 3 / 2;
        } while (y <= vLim);
        _layers.add(layer);
      }
    }

    final ct = t % (_nl * _dpl);
    final n = (ct / _dpl).floor();
    final st = ct / _dpl % 1;

    final currentLayer = layers[n];
    final nextLayer = layers[(n + 1) % _nl];
    final nextNextLayer = layers[(n + 2) % _nl];

    // Optimization of drawing the next next layer is simply taking the color
    // of that layer and drawing that since the layer should completely tile
    // the screen.
    c.drawColor(nextNextLayer.first.color, BlendMode.srcOver);

    for (final hexagon in nextLayer) {
      var p = 2 - (-hexagon.time + st);
      if (p >= 1) {
        // Fully-sized hexagon without anti-aliasing for perfect tiling.
        hexagon.draw(c, _r, false);
        continue;
      }
      p = 1 - _curve.transform(1 - p);
      hexagon.draw(c, _r * p, true);
    }
    for (final hexagon in currentLayer) {
      var p = 1 - (-hexagon.time + st);
      if (p <= 0) continue;
      p = 1 - _curve.transform(1 - p);
      hexagon.draw(c, _r * p, true);
    }
  }
}

typedef _Layer = List<_TimedRegularHexagon>;

final _sqrt3 = sqrt(3);

class _TimedRegularHexagon {
  _TimedRegularHexagon(this.x, this.y, this.time, this.color);

  final double x, y;
  final double time;
  final Color color;

  void draw(Canvas canvas, double radius, bool isAntiAlias) {
    if (radius <= 0) return;

    final points = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final angle = pi / 3 * i + pi / 2;

      points.add(Offset(
        x + radius * cos(angle),
        y + radius * sin(angle),
      ));
    }
    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()
        ..color = color
        // For perfect tiling, anti-aliasing needs to be turned off.
        ..isAntiAlias = isAntiAlias,
    );
  }
}
