import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:funvas/funvas.dart';

class FortyThree extends Funvas {
  @override
  void u(double t) {
    const d = 750.0;
    s2q(d);
    c.translate(d / 2, d / 2);

    const r = 90.0;
    const sr = r / 2;

    final dt = t % 12;
    final sh = dt > 6;
    final ct = t % 6;

    final bgc = Color.lerp(
      sh ? const Color(0xffffffff) : const Color(0xff000000),
      sh ? const Color(0xff000000) : const Color(0xffffffff),
      ct > 4
          ? 1
          : ct > 3
              ? ct - 3
              : 0,
    )!;
    c.drawColor(bgc, BlendMode.srcOver);

    final mp = ct / 3 > 1 ? 1 : Curves.easeOutQuad.transform(ct / 3);

    const co = Offset.zero;
    final to = Offset.lerp(const Offset(0, -r), co, mp - 1 / 2)!;
    final blo = Offset.lerp(Offset(-r * _sqrt3 / 2, r / 2), co, mp - 1 / 2)!;
    final bro = Offset.lerp(Offset(r * _sqrt3 / 2, r / 2), co, mp - 1 / 2)!;

    final bigPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addPolygon(_buildTriangleVertices(to, r), false)
      ..addPolygon(_buildTriangleVertices(blo, r), false)
      ..addPolygon(_buildTriangleVertices(bro, r), false);
    c.drawPath(
      bigPath,
      Paint()..color = sh ? const Color(0xff000000) : const Color(0xffffffff),
    );

    if (ct > 5) {
      final st = Offset.lerp(
        const Offset(0, -sr),
        const Offset(0, -r) * 1.5,
        ct - 5,
      )!;
      final sbl = Offset.lerp(
        Offset(-sr * _sqrt3 / 2, sr / 2),
        Offset(-r * _sqrt3 / 2, r / 2) * 1.5,
        ct - 5,
      )!;
      final sbr = Offset.lerp(
        Offset(sr * _sqrt3 / 2, sr / 2),
        Offset(r * _sqrt3 / 2, r / 2) * 1.5,
        ct - 5,
      )!;

      final rp = lerpDouble(sr, r, ct - 5)!;
      final smallPath = Path()
        ..addPolygon(_buildTriangleVertices(st, rp), false)
        ..addPolygon(_buildTriangleVertices(sbl, rp), false)
        ..addPolygon(_buildTriangleVertices(sbr, rp), false);
      c.drawPath(
        smallPath,
        Paint()..color = sh ? const Color(0xffffffff) : const Color(0xff000000),
      );
    } else {
      if (ct > 4) {
        c.rotate(pi * (ct - 4));
      }

      if (ct > 3) {
        const sb = Offset(0, sr);
        final stl = Offset(-sr * _sqrt3 / 2, -sr / 2);
        final str = Offset(sr * _sqrt3 / 2, -sr / 2);

        final xa = -max(0, ct - 4) * pi;

        final smallPath = Path()
          ..addPolygon(_buildTriangleVertices(sb, sr, xa), false)
          ..addPolygon(_buildTriangleVertices(stl, sr, xa), false)
          ..addPolygon(_buildTriangleVertices(str, sr, xa), false);
        c.drawPath(
          smallPath,
          Paint()
            ..color = sh ? const Color(0xffffffff) : const Color(0xff000000),
        );
      }
    }
  }
}

final _sqrt3 = sqrt(3);

List<Offset> _buildTriangleVertices(Offset center, double r, [double a = 0]) {
  return [
    Offset.fromDirection(-pi / 2 + a, r) + center,
    Offset.fromDirection(pi * 2 / 3 - pi / 2 + a, r) + center,
    Offset.fromDirection(pi * 4 / 3 - pi / 2 + a, r) + center,
  ];
}
