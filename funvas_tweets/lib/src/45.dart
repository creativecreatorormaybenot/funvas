import 'dart:async';
import 'dart:math';
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

    c.translate(d / 2, d / 4);
    c.scale(1 + t % 6);
    c.translate(-d / 2, d / -4);

    final scale = d / max(_w, _h);
    final monaLisas = <RSTransform>[
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale,
        anchorX: 0,
        anchorY: 0,
        translateX: _w * scale / 4,
        translateY: 0,
      ),
      RSTransform.fromComponents(
        rotation: 0,
        scale: scale / 142,
        anchorX: _w / 2,
        anchorY: _h / 2,
        translateX: _w * scale / 4 + _w * scale / 2.468,
        translateY: _h * scale / 4.297,
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
    c.drawImage(monaLisa, const Offset(_w / 4, 0), Paint());
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
