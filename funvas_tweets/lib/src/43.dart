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

    final dt = t % 8;
    final sh = dt > 4;
    final ct = t % 4;

    final bgc = Color.lerp(
      sh ? const Color(0xffffffff) : const Color(0xff000000),
      sh ? const Color(0xff000000) : const Color(0xffffffff),
      ct > 2.5
          ? 1
          : ct > 2
              ? (ct - 2) * 2
              : 0,
    )!;
    c.drawColor(bgc, BlendMode.srcOver);

    final mp = ct / 2 > 1 ? 1 : Curves.easeInOutQuad.transform(ct / 2);

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

    if (ct > 2) {
      final sp = Curves.fastOutSlowIn.transform(max(.0, (ct - 2.5) / 3 * 2));
      final xa = -sp * pi;
      final rp = lerpDouble(sr, r, sp)!;

      c.rotate(pi * sp);

      final sb = Offset.lerp(
        const Offset(0, sr),
        const Offset(0, 1.5 * r),
        sp,
      )!;
      final stl = Offset.lerp(
        Offset(-sr * _sqrt3 / 2, -sr / 2),
        Offset(-1.5 * r * _sqrt3 / 2, -1.5 * r / 2),
        sp,
      )!;
      final str = Offset.lerp(
        Offset(sr * _sqrt3 / 2, -sr / 2),
        Offset(1.5 * r * _sqrt3 / 2, -1.5 * r / 2),
        sp,
      )!;

      final smallPath = Path()
        ..addPolygon(_buildTriangleVertices(sb, rp, xa), false)
        ..addPolygon(_buildTriangleVertices(stl, rp, xa), false)
        ..addPolygon(_buildTriangleVertices(str, rp, xa), false);
      c.drawPath(
        smallPath,
        Paint()..color = sh ? const Color(0xffffffff) : const Color(0xff000000),
      );
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
