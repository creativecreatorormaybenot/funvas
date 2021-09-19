import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/funvas_tweets.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

/// Variation of [FortyOne].
class FortyTwo extends Funvas {
  late final _noise = OpenSimplex2F(420);
  final _layers = <_Layer>[];

  @override
  void u(double t) {
    t = -t;
    const d = 750.0, r = 50.0;
    const nl = 2, dpl = 3;
    s2q(d);

    const vLim = d + r;
    final hLim = d + r * _sqrt3 / 2;

    if (_layers.isEmpty) {
      for (var i = 0; i < nl; i++) {
        final layer = <_TimedRegularHexagon>[];
        var y = .0, alt = false;
        do {
          for (var x = alt ? .0 : _sqrt3 * r / 2; x <= hLim; x += _sqrt3 * r) {
            final time = _noise.noise3XYBeforeZ(
              x / d * 10,
              y / d * 10,
              i / 1,
            );
            layer.add(_TimedRegularHexagon(x, y, (time - 1) / 2, i % 2 == 0));
          }
          alt = !alt;
          y += r * 3 / 2;
        } while (y <= vLim);
        _layers.add(layer);
      }
    }

    final ct = t % (nl * dpl);
    final n = (ct / dpl).floor();
    final st = ct / dpl % 1;

    final currentLayer = _layers[n];
    final nextLayer = _layers[(n + 1) % nl];
    final nextNextLayer = _layers[(n + 2) % nl];

    // Optimization of drawing the next next layer is simply taking the color
    // of that layer and drawing that since the layer should completely tile
    // the screen.
    c.drawColor(nextNextLayer.first.baseColor, BlendMode.srcOver);

    for (final hexagon in nextLayer) {
      var p = 2 - (-hexagon.time + st);
      hexagon.drawPhaseOne(c, r, p);
    }
    for (final hexagon in currentLayer) {
      var p = 1 - (-hexagon.time + st);
      hexagon.drawPhaseTwo(c, r, p);
    }
  }
}

typedef _Layer = List<_TimedRegularHexagon>;

final _sqrt3 = sqrt(3);
const _curve = Curves.fastOutSlowIn;

class _TimedRegularHexagon {
  _TimedRegularHexagon(this.x, this.y, this.time, this.alt);

  final double x, y;
  final double time;
  final bool alt;

  Color get baseColor {
    return alt ? const Color(0xffffffff) : const Color(0xff000000);
  }

  void drawPhaseOne(Canvas c, double r, double p) {
    drawChromatic(p, (p, paint) {
      if (p >= 1) {
        draw(
          c,
          r,
          0,
          Paint()
            ..color = baseColor
            // Without anti-aliasing for perfect tiling.
            ..isAntiAlias = false,
        );
        return;
      }
      if (p <= 0) return;
      p = _curve.transform(p);
      draw(c, r * p, 2 * pi * p * (alt ? 1 : -1 / 2), paint);
    });
  }

  void drawPhaseTwo(Canvas c, double r, double p) {
    drawChromatic(p, (p, paint) {
      if (p <= 0) return;
      p = _curve.transform(p);
      draw(c, r * p, 2 * pi * p * (alt ? 1 : -1 / 2), paint);
    });
  }

  void drawChromatic(double p, void Function(double p, Paint paint) callback) {
    if (baseColor == const Color(0xff000000)) {
      callback(p, Paint()..color = baseColor);
      return;
    }
    callback(
      p,
      Paint()
        ..color = Color(baseColor.value & 0xffff0000)
        ..blendMode = BlendMode.plus,
    );
    callback(
      p - 1 / 25,
      Paint()
        ..color = Color(baseColor.value & 0xff00ff00)
        ..blendMode = BlendMode.plus,
    );
    callback(
      p - 1 / 25 * 2,
      Paint()
        ..color = Color(baseColor.value & 0xff0000ff)
        ..blendMode = BlendMode.plus,
    );
  }

  void draw(Canvas canvas, double radius, double a, Paint paint) {
    if (radius <= 0) return;

    final points = <Offset>[];
    for (var i = 0; i < 6; i++) {
      final angle = pi / 3 * i + pi / 2 + a;

      points.add(Offset(
        x + radius * cos(angle),
        y + radius * sin(angle),
      ));
    }
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }
}
