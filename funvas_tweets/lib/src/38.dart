import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:funvas/funvas.dart';
import 'package:open_simplex_2/open_simplex_2.dart';

class ThirtyEight extends Funvas {
  ThirtyEight() {
    _loadImage();
  }

  static const _d = 750.0, _ps = 42, _duration = 5.0, _n = 9999, _sn = 99;

  static const _particleProvider = ResizeImage(
    NetworkImage(
      'https://i.imgur.com/skxsba4.png',
    ),
    width: _ps,
    height: _ps,
  );

  Image? _particle;

  double? _pt;
  late double _it;

  @override
  void u(double t) {
    if (_particle == null) {
      return;
    }

    final pt = _pt;
    if (pt == null || pt > t) {
      _init(_pt = t);
      _advance(t, t - _it);
    } else {
      _advance(t - pt, t - _it);
      _pt = t;
    }

    _draw();
  }

  Future<void> _loadImage() async {
    final completer = Completer<Image>();
    final listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
    });

    final stream = _particleProvider.resolve(const ImageConfiguration())
      ..addListener(listener);
    _particle = await completer.future;
    stream.removeListener(listener);
  }

  final _noise = OpenSimplex2F(42);
  final _particles = <_Particle>[];

  void _init(double t) {
    _particles.clear();
    _it = t;
    _particles.add(_Particle.basedOnTime(t, _duration, _noise, 0));
  }

  void _advance(double dt, double t) {
    if (dt <= 0) return;

    for (final particle in _particles) {
      particle.advance(dt, _d);
    }
    _particles.removeWhere((element) => element.oob(_d, _ps / 1));

    final offsets = [
      for (var i = 0; i < _sn; i++) 2 * pi / _sn * i,
    ];
    for (final o in offsets) {
      if (_particles.length >= _n) break;
      _particles.add(_Particle.basedOnTime(t, _duration, _noise, o));
    }
  }

  void _draw() {
    s2q(_d);
    c.drawColor(const Color(0xff3a3a3a), BlendMode.srcOver);

    c.save();
    c.translate(_d / 2, _d / 2);
    c.drawAtlas(
      _particle!,
      [
        for (final particle in _particles)
          RSTransform.fromComponents(
            rotation: particle.v.direction + pi / 4,
            scale: particle.scale,
            anchorX: _ps / 2,
            anchorY: _ps / 2,
            translateX: particle.p.dx,
            translateY: particle.p.dy,
          ),
      ],
      List.filled(
        _particles.length,
        const Rect.fromLTWH(0, 0, _ps / 1, _ps / 1),
      ),
      [
        for (final particle in _particles)
          HSLColor.fromAHSL(
            min(0.5, particle.p.distanceSquared / (_d * 3e2)),
            particle.hue,
            3 / 4,
            3 / 4,
          ).toColor(),
      ],
      BlendMode.modulate,
      const Rect.fromLTWH(-_d / 2, -_d / 2, _d, _d),
      Paint(),
    );
    c.restore();

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${_particles.length} rockets',
        style: const TextStyle(
          fontSize: 24,
          backgroundColor: Color(0xff000000),
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      c,
      Offset(_d - textPainter.width, _d - textPainter.height),
    );
  }
}

class _Particle {
  _Particle(this.v, this.hue, this.scale);

  factory _Particle.basedOnTime(
    double t,
    double D,
    OpenSimplex2 noise,
    double o,
  ) {
    final tp = t / D % 1 * pi * 2;

    final pn = noise.noise2(sin(tp) - o, cos(tp) + o);
    final vn = noise.noise2(4.2 + cos(tp), sin(tp) - 4.2);
    final cn = noise.noise2(-6.9 + cos(tp * 5), sin(tp * 5) + 6.9);
    final sn = noise.noise2(cos(tp * 5) + o, sin(tp * 5) - o);
    return _Particle(
      Offset.fromDirection(pn * pi * 4, 3 + vn * 2),
      180 + 180 * cn,
      1.1 + sn * 2,
    );
  }

  final Offset v;

  final double hue;
  final double scale;

  /// Position of the particle relative to the center (0, 0).
  var p = Offset.zero;

  void advance(double dt, double d) {
    p += v * dt * d / 9;
  }

  bool oob(double d, double s) {
    final dx = p.dx.abs(), dy = p.dy.abs();
    if (dx - s / 2 * scale > d / 2) return true;
    if (dy - s / 2 * scale > d / 2) return true;
    return false;
  }
}
