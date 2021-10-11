import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:funvas/funvas.dart';

class FortyFive extends Funvas {
  FortyFive() {
    _loadImage();
  }

  static const _w = 3355, _h = 5000;

  static const _monaLisaProvider = ResizeImage(
    NetworkImage(
      'https://firebasestorage.googleapis.com/v0/b/funvas-cdf8b.appspot.com/o/'
      'mona_lisa.png?alt=media&token=6395033b-e312-4dfe-86d8-d64ed9041860',
    ),
    width: _w,
    height: _h,
  );

  Image? _monaLisa;

  @override
  void u(double t) {
    final monaLisa = _monaLisa;
    if (monaLisa == null) return;

    const d = 750.0;
    s2q(d);
    const scale = d / _h, smallerScale = scale / 142;
    const scaledH = _h * scale, scaledW = _w * scale;

    const relativeX = -0.0954, relativeY = 0.2345;
    const relativeWidthGap = (_h - _w) / _h / 2;

    const dx = relativeWidthGap * d +
            scaledW / 2 +
            scaledW * relativeX +
            _w * smallerScale * relativeX * 0.25,
        dy = scaledH * relativeY - _h * smallerScale * relativeY * 2.25;
    c.translate(dx, dy);
    c.scale(1);
    c.translate(-dx, -dy);

    final monaLisas = <RSTransform>[
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: _w / 2,
        anchorY: 0,
        translateX: d / 2,
        translateY: 0,
      ),
      RSTransform.fromComponents(
        rotation: 0,
        scale: smallerScale,
        anchorX: _w / 2 + _w * relativeX,
        anchorY: _h / 2 + _h * relativeY,
        translateX: d / 2 + scaledW * relativeX,
        translateY: scaledH * relativeY,
      ),
    ];

    c.drawAtlas(
      monaLisa,
      monaLisas,
      [
        for (var i = 0; i < monaLisas.length; i++)
          const Rect.fromLTWH(0, 0, _w / 1, _h / 1),
      ],
      null,
      null,
      null,
      Paint(),
    );
  }

  Future<void> _loadImage() async {
    final completer = Completer<Image>();
    final listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
    }, onError: (e, s) {
      print(e);
    }, onChunk: (chunk) {
      print(chunk.cumulativeBytesLoaded);
    });

    final stream = _monaLisaProvider.resolve(const ImageConfiguration())
      ..addListener(listener);
    _monaLisa = await completer.future;
    stream.removeListener(listener);
  }
}
