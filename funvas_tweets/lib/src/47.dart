import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/tweet_mixin.dart';

class FortySeven extends Funvas with FunvasTweetMixin {
  @override
  String get tweet =>
      'https://twitter.com/creativemaybeno/status/1451601351318941702?s=20';

  @override
  void u(double t) {
    c.drawColor(const Color(0xffffffff), BlendMode.srcOver);
    const d = 750.0;
    s2q(d);

    const scaleFactor = 24.0;
    const targetZoom = scaleFactor * scaleFactor;

    const zoomTime = 2, rotationTime = 3 * zoomTime;

    // Taking the log_2(targetZoom) gives us the exponent we need to achieve
    // our target zoom when zooming at an exponential rate.
    final exponentNeeded = log(targetZoom) / log(2);
    final exponent = exponentNeeded / zoomTime * (t % zoomTime);

    // We need to zoom in at an exponential rate in order to make it *look
    // like* we are zooming in at a linear rate. This is because changing the
    // scale from 1 to 2 makes everything twice as big but scaling from 2 to 3
    // only 50% bigger.
    final zoom = pow(2, exponent) / 1;

    // Center the origin.
    c.translate(d / 2, d / 2);
    c.rotate(t / rotationTime * pi * 2);
    c.translate(d / 4, 0);
    c.scale(zoom);

    var inverted = false;
    // We need to draw the logo in larger as a background twice initially
    // because some of the lines do not perfectly line up and you
    // can see through the logo.
    var scale = scaleFactor * scaleFactor * scaleFactor;
    do {
      inverted = !inverted;
      scale /= scaleFactor;
      if (zoom *
              scale *
              166 /
              // We need to remove the extra larger copies that only act as
              // background because the larger ones create some real bad
              // artifacts as you continue to zoom in.
              scaleFactor /
              scaleFactor /
              scaleFactor >
          d) {
        continue;
      }

      c.save();
      c.scale(scale);
      _drawFlutterLogo(t, inverted);
      c.restore();
    } while (zoom * scale * 166 > 1);
  }

  /// Paints the Flutter logo based on the code from [FlutterLogo].
  ///
  /// The logo takes up 166x202 pixels and is drawn centered.
  void _drawFlutterLogo(double t, [bool invert = false]) {
    c.save();

    // todo: live demo

    // We translate so that the top right of the triangle shadow is at (0, 0).
    c.translate(-107.4, -142.8);

    final lightPaint = Paint()
      ..color = invert ? const Color(0xffab3a07) : const Color(0xFF54C5F8);
    final mediumPaint = Paint()
      ..color = invert ? const Color(0xffd64909) : const Color(0xFF29B6F6);
    final darkPaint = Paint()
      ..color = invert ? const Color(0xfffea864) : const Color(0xFF01579B);

    final triangleGradient = Gradient.linear(
      const Offset(87.2623 + 37.9092, 28.8384 + 123.4389),
      const Offset(42.9205 + 37.9092, 35.0952 + 123.4389),
      <Color>[
        const Color(0x001A237E),
        const Color(0x661A237E),
      ],
    );
    final trianglePaint = Paint()..shader = triangleGradient;

    final topBeam = Path()
      ..moveTo(37.7, 128.9)
      ..lineTo(9.8, 101.0)
      ..lineTo(100.4, 10.4)
      ..lineTo(156.2, 10.4);
    c.drawPath(topBeam, lightPaint);

    final middleBeam = Path()
      ..moveTo(156.2, 94.0)
      ..lineTo(100.4, 94.0)
      ..lineTo(78.5, 115.9)
      ..lineTo(106.4, 143.8);
    c.drawPath(middleBeam, lightPaint);

    final bottomBeam = Path()
      ..moveTo(79.5, 170.7)
      ..lineTo(100.4, 191.6)
      ..lineTo(156.2, 191.6)
      ..lineTo(107.4, 142.8);
    c.drawPath(bottomBeam, darkPaint);

    c.save();
    c.transform(Float64List.fromList(const <double>[
      // careful, this is in _column_-major order
      0.7071, -0.7071, 0.0, 0.0,
      0.7071, 0.7071, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      -77.697, 98.057, 0.0, 1.0,
    ]));
    c.drawRect(const Rect.fromLTWH(59.8, 123.1, 39.4, 39.4), mediumPaint);
    c.restore();

    final triangle = Path()
      ..moveTo(79.5, 170.7)
      ..lineTo(120.9, 156.4)
      ..lineTo(107.4, 142.8);
    if (!invert) c.drawPath(triangle, trianglePaint);
    c.restore();
  }
}
