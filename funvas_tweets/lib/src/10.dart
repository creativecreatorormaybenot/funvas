import 'dart:ui';

import 'package:funvas/funvas.dart';

class Ten extends Funvas {
  @override
  void u(double t) {
    c.drawRect(Offset.zero & Size(x.width, x.height),
        Paint()..color = const Color(0xffff0000));
  }
}
