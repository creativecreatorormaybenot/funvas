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

  static const _d = 750.0, _ps = 42, _duration = 11.0, _n = 4200, _sn = 12;

  static const _particleProvider = ResizeImage(
    NetworkImage(
      'https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/'
      'thumbs/160/apple/96/rocket_1f680.png',
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

  final _noise = OpenSimplex2S(42);
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
    c.translate(_d / 2, _d / 2);

    c.drawAtlas(
      _particle!,
      [
        for (final particle in _particles.reversed)
          RSTransform.fromComponents(
            rotation: particle.v.direction - pi / 4,
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
        for (final particle in _particles.reversed)
          HSLColor.fromAHSL(1, particle.hue, 3 / 4, 3 / 4).toColor(),
      ],
      BlendMode.luminosity,
      const Rect.fromLTWH(-_d / 2, -_d / 2, _d, _d),
      Paint(),
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

    final vn = noise.noise2(4.2 + cos(tp), sin(tp) - 4.2);
    final cn = noise.noise2(-6.9 + cos(tp * 5), sin(tp * 5) + 6.9);
    final sn = noise.noise2(cos(tp * 5) + o, sin(tp * 5) - o);
    return _Particle(
      Offset.fromDirection((tp + o) % (2 * pi), 1.5 + vn),
      180 + 180 * cn,
      1.5 + sn,
    );
  }

  final Offset v;

  final double hue;
  final double scale;

  /// Position of the particle relative to the center (0, 0).
  var p = Offset.zero;

  void advance(double dt, double d) {
    p += v * dt * d / 2;
  }

  bool oob(double d, double s) {
    final dx = p.dx.abs(), dy = p.dy.abs();
    if (dx - s / 2 * scale > d / 2) return true;
    if (dy - s / 2 * scale > d / 2) return true;
    return false;
  }
}
