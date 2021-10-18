import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:funvas/src/painter.dart';

void main() {
  test('funvas context provides size as expected', () {
    const size = Size(42, 42);
    final funvas = _TestFunvas();
    funvas.x = const FunvasContext(size);

    expect(funvas.x.width, 42);
    expect(funvas.x.height, 42);
    expect(funvas.s, size);
  });
}

class _TestFunvas extends Funvas {
  @override
  void u(double t) {}
}
