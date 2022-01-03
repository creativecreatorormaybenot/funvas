import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funvas/funvas.dart';

class FortyNine extends Funvas {
  FortyNine() {
    _init();
  }

  FragmentProgram? _fragmentProgram;

  Future<void> _init() async {
    final byteData = await rootBundle.load('shaders/spir-v/water_lights.sprv');
    _fragmentProgram = await FragmentProgram.compile(
      spirv: byteData.buffer,
    );
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
