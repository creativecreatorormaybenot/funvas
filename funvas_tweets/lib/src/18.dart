import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

class Eighteen extends Funvas {
  Eighteen() {
    final random = Random();
    _sides = List.generate(_n, (index) => random.nextInt(5) + 3);
  }

  /// The number of sides for the polygons to be drawn.
  ///
  /// The values are chosen randomly but persist between the different phases.
  late final List<int> _sides;

  /// The distances for the polygons from the bottom center.
  static const List<double> _distances = [
    .35,
    .35,
    .6,
    .2,
    .5,
    .62,
    .76,
    .43,
    .9,
    .86,
    .95,
    .7,
  ];

  /// The angle for the polygons travelling the [_distances].
  static const List<double> _angles = [
    -pi / 2.7,
    -pi / 8,
    -pi / 5.5,
    pi / 9,
    pi / 8,
    0,
    -pi / 10,
    pi / 3.2,
    pi / 7.6,
    pi / 20,
    -pi / 8,
    pi / 7,
  ];

  static const _n = 12;

  @override
  void u(double t) {
    final s = s2q(750), r = Offset.zero & s;
    c.drawColor(const Color(0xffffc108), BlendMode.srcOver);

    // Looping t that loops every 6 seconds.
    final lt = t % 8;
    if (lt < 1) {
      _phase0(lt, r);
    } else if (lt < 4) {
      _phase1(lt - 1, r);
    } else if (lt < 6) {
      _phase2(lt - 4, r);
    } else {
      _phase3(lt - 6, r);
    }
  }

  Offset _offset(int index, double progress, Rect r) {
    final tp = Curves.fastOutSlowIn.transform(progress);
    return r.bottomCenter +
        Offset(0, r.shortestSide / 8 * (1 - tp)) +
        Offset.fromDirection(
          _angles[index] - pi / 2,
          _distances[index] * r.shortestSide * tp,
        );
  }

  Paint get _polyPaint {
    return Paint()
      ..color = const Color(0xff02569b)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
  }

  Paint _circlePaint(double opacity) {
    return Paint()..color = const Color(0xff02569b).withOpacity(opacity);
  }

  void _phase0(double t, Rect r) {
    for (var i = 0; i < _n; i++) {
      c.drawRegularPolygon(
        center: _offset(i, t.clamp(0, 1), r),
        rotation: (t.clamp(1, 6) - 1) * pi,
        radius: r.shortestSide / 12,
        vertices: _sides[i],
        paint: _polyPaint,
      );
    }
  }

  void _phase1(double t, Rect r) {
    for (var i = 0; i < _n; i++) {
      c.drawRegularPolygon(
        center: _offset(i, 1, r),
        rotation: (t + 1) * pi,
        radius: r.shortestSide / 12,
        vertices: _sides[i] + t * 6 ~/ 1,
        paint: _polyPaint,
      );
    }
  }

  void _phase2(double t, Rect r) {
    for (var i = 0; i < _n; i++) {
      c.drawRegularPolygon(
        center: Offset.lerp(
          _offset(i, 1, r),
          r.center,
          Curves.ease.transform(t.clamp(0, 1)),
        )!,
        radius: r.shortestSide / 12,
        vertices: 99,
        paint: _polyPaint,
      );
    }

    c.drawCircle(
      r.center,
      r.shortestSide / 11.5,
      _circlePaint(Curves.fastOutSlowIn.transform((t - 1).clamp(0, 1))),
    );
  }

  void _phase3(double t, Rect r) {
    c.drawCircle(
      r.center,
      r.shortestSide / 11.5 * (1 + Curves.fastOutSlowIn.transform(t / 2) * 4),
      _circlePaint(1 - Curves.fastOutSlowIn.transform(t / 2)),
    );
  }
}

extension on Canvas {
  void drawRegularPolygon({
    required Offset center,
    required double radius,
    required int vertices,
    double rotation = 0,
    required Paint paint,
  }) {
    assert(radius > 0);
    assert(vertices > 2);

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
        radius * cos(angle),
        radius * sin(angle),
      ));
    }

    save();
    translate(center.dx, center.dy);
    rotate(rotation);
    drawPath(Path()..addPolygon(points, true), paint);
    restore();
  }
}
