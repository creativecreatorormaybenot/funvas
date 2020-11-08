part of tweets;

class _One extends Funvas {
  @override
  void u(double t) {
    final w = x.width,
        h = x.height,
        m = min(w, h),
        center = Offset(w / 2, h / 2);

    // Draw background.
    c.drawPaint(Paint()..color = R(242, 227, 193));

    final outer = m * (.4 + C(t / 9) * .04);

    // Draw background circle.
    c.drawCircle(
      center,
      outer,
      Paint()..color = R(50, 71, 104),
    );

    const padding = 8;

    // Draws a small circle.
    void sc(double delta, double radius) {
      final offset = center +
          Offset.fromDirection(
              T(S(t + delta * 1.7)) * pi * 2, outer - padding - radius);

      c.drawCircle(
          offset,
          radius,
          Paint()
            ..color =
                R(200 + delta * 40, 100 + delta * 80, 100, .1 + delta / 3));
    }

    for (int i = 16; i > 0; i--) {
      sc(i / 2 / 10, 120.0 - i * 7);
    }
  }
}
