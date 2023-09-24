import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';

class FiftyOne extends Funvas {
  @override
  void u(double t) {
    const d = 750.0;
    s2q(d);
    c.drawColor(const Color(0xff000000), BlendMode.srcOver);
  }
}
