# funvas [![GitHub stars](https://img.shields.io/github/stars/creativecreatorormaybenot/funvas.svg)](https://github.com/creativecreatorormaybenot/funvas) [![Pub version](https://img.shields.io/pub/v/funvas.svg)](https://pub.dev/packages/funvas) [![Twitter Follow](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow&style=social)](https://twitter.com/creativemaybeno)

Flutter package that allows creating canvas animations based on time and math functions.

The name "funvas" is based on Flutter + fun + canvas. Let me know if you have any better ideas :)

## Concept

The idea of the package is to provide an easy way to create custom canvas animations based only
on time and some math functions (sine, cosine, etc.) - like [this one][Twitter].

<a target="_blank" href="https://twitter.com/creativemaybeno/status/1328261273922973696?s=20"><img src="https://s8.gifyu.com/images/animation8709ccbbf7b20e6e.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1327309901270560769?s=20"><img src="https://s8.gifyu.com/images/animation8709ccbbf7b20e6f.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1377705763402039303?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479453-b9dd2480-947e-11eb-88b6-4ef3835e0a29.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1360867891906830336?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479456-bfd30580-947e-11eb-9a3a-f807299a289a.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1346101868079042561?s=20"><img src="https://s2.gifyu.com/images/animation053c9f614aad68ef.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1349343188247404548?s=20"><img src="https://s2.gifyu.com/images/animationbfc096a486621405.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1369749942080839680?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479483-e8f39600-947e-11eb-858b-ec3fe980f2b2.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1370328227479191553?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479485-ec871d00-947e-11eb-863b-4dac2a92c6e4.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1350085831550148611?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479488-f01aa400-947e-11eb-81c4-e4394ec20b01.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1364560611435307008?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479491-f1e46780-947e-11eb-9bb2-f43748651700.gif" width="49%"></a>

*Inspired by Dwitter* ([check it out][Dwitter]). This is also the reason why
the following shortcut functions and variables are available; they might be expanded upon in the
future given that there are a lot more possibilities:

```text
u(t) is called 60 times per second.
    t: Elapsed time in seconds.
    S: Shorthand for sin from dart:math.
    C: Shorthand for cos from dart:math.
    T: Shorthand for tan from dart:math.
    R: Shorthand for Color.fromRGBA, usage ex.: R(255, 255, 255, 0.5)
    c: A dart:ui canvas.
    x: A context for the canvas, providing size.
```

You can of course use all of the `Canvas` functionality, the same way you can use them in a
`CustomPainter`; the above is just in homage to Dwitter :)

## Usage

You create funvas animations by extending `Funvas` and you can display the animations using a
[FunvasContainer].
Note that you have to size the animation from outside, e.g. using a [SizedBox].

```dart
import 'package:flutter/material.dart';
import 'package:funvas/funvas.dart';

/// Example implementation of a funvas.
///
/// The animation is drawn in [u] based on [t] in seconds.
class ExampleFunvas extends Funvas {
  @override
  void u(double t) {
    c.drawCircle(
      Offset(x.width / 2, x.height / 2),
      S(t).abs() * x.height / 4 + 42,
      Paint()..color = R(C(t) * 255, 42, 60 + T(t)),
    );
  }
}

/// Example widget that displays the [ExampleFunvas] animation.
class ExampleFunvasWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      height: 420,
      child: FunvasContainer(
        funvas: ExampleFunvas(),
      ),
    );
  }
}
```

See the [example package][example] for a complete example implementation.

## Gallery & more

Funvas is a package that I wrote because I wanted to create some Dwitter-like animations in Flutter
myself.
Because of that, I have created a lot surrounding it, which you might not discover when looking only
at the package :)

To see a live demo (gallery app) and many fun(vas) animations, you can see the
[main README on GitHub][repo] :)

[Twitter]: https://twitter.com/creativemaybeno/status/1285343758247178240?s=20
[Dwitter]: https://www.dwitter.net/about
[example]: https://github.com/creativecreatorormaybenot/funvas/tree/master/example
[repo]: https://github.com/creativecreatorormaybenot/funvas
[SizedBox]: https://api.flutter.dev/flutter/widgets/SizedBox-class.html
[FunvasContainer]: https://pub.dev/documentation/funvas/latest/funvas/FunvasContainer-class.html
