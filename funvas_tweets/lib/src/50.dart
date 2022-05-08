import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';
import 'package:funvas_tweets/src/future_mixin.dart';

class Fifty extends Funvas with FunvasFutureMixin {
  Fifty() {
    _init();
  }

  final _completer = Completer<FragmentProgram>();
  FragmentProgram? _fragmentProgram;

  @override
  Future get future => _completer.future;

  Future<void> _init() async {
    final byteData = await rootBundle.load(
      'packages/funvas_tweets/shaders/spir-v/50.sprv',
    );
    _completer.complete(_fragmentProgram = await FragmentProgram.compile(
      spirv: byteData.buffer,
    ));
  }

  @override
  void u(double t) {
    final fragmentProgram = _fragmentProgram;
    if (fragmentProgram == null) return;

    final shader = fragmentProgram.shader(
      floatUniforms: Float32List.fromList([x.width, x.height, t]),
    );
    c.drawRect(Offset.zero & x.size, Paint()..shader = shader);
  }
}
