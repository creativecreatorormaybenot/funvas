import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class Six extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1330866943335796741?s=20';

  final _polygons = <_RegularPolygon>[];
  Offset? _memoizedCenter;

  void _setupPolygons(Offset center) {
    if (_memoizedCenter == center) return;

    _memoizedCenter = center;
    _polygons.clear();

    for (var i = 3; i < 16; i++) {
      _polygons.add(_RegularPolygon(
        center: center,
        vertices: i,
        radius: 40 + i * 20,
      ));
    }
  }

  @override
  void u(double t) {
    // Scale to match 750x750 as this is the export size and keep aspect ratio.
    final s = s2q(750), w = s.width, h = s.height;

    c.drawPaint(Paint()..color = const Color(0xffffffff));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final center = Offset(w / 2, h / 2);
    _setupPolygons(center);
    // Time it takes for the outermost dot to travel its polygon (lap time).
    var T = 20;
    c.translate(w / 2, h / 2);
    c.rotate(2 * pi * t / T * 2);
    c.translate(-w / 2, h / -2);

    for (var i = _polygons.length - 1; i >= 0; i--) {
      _polygons[i].draw(
          c,
          paint
            // I actually did not intend the colors to turn out the exact same
            // way as the original - this is just what I am used to from
            // Dwitter.
            ..color = HSVColor.fromAHSV(1, 360 / _polygons.length * i, .7, .9)
                .toColor());
    }
    for (var i = 0; i < _polygons.length; i++) {
      final metric = _polygons[i].path.computeMetrics().first;

      final progress = t /
          (T /
              // This will make the second outermost dot complete 2 laps in the
              // same time the outermost performs 1 etc.
              (_polygons.length - i));

      final point = metric
          .getTangentForOffset(metric.length *
              (1 -
                  (progress -
                          // This aligns the dots at the bottom center at the start.
                          // The logic is that we want to move half the distance
                          // between each vertex. If the whole distance of the path
                          // is 1, then the distance between each vertex is
                          // 1 / vertices → half of that distance is
                          // 1 / (vertices * 2). We add 3 to i because the first
                          // polygon has 3 vertices and i starts at 0.
                          1 / ((i + 3) * 2)) %
                      1))!
          .position;
      c.drawCircle(point, 7.5, Paint());
    }
  }
}

class _RegularPolygon {
  _RegularPolygon({
    required this.center,
    required this.radius,
    required this.vertices,
  })  : assert(radius > 0),
        assert(vertices > 2) {
    _init();
  }

  final Offset center;
  final double radius;
  final int vertices;

  Path get path => _path;
  late final Path _path;

  void _init() {
    final points = <Offset>[];

    for (var i = 0; i < vertices; i++) {
      // As I am trying to imitate https://twitter.com/beesandbombs/status/870061547137236992?s=20,
      // I want to position the polygons in a way where there are always two
      // vertices at the bottom in the exact same horizontal positions.
      final angle = 2 *
              pi /
              vertices *
              (i -
                  // The half the angle of the difference between the vertices
                  // for initial rotation of each polygon (for i = 0) was just
                  // intuition when looking at the original animation.
                  1 / 2)
          // The quarter rotation just aligns it correctly.
          +
          pi / 2;

      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }

    _path = Path()..addPolygon(points, true);
  }

  void draw(Canvas canvas, Paint paint) {
    canvas.drawPath(_path, paint);
  }
}
