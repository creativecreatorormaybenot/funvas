# funvas [![Publish workflow](https://github.com/creativecreatorormaybenot/funvas/workflows/Publish/badge.svg)](https://github.com/creativecreatorormaybenot/funvas/actions) [![GitHub stars](https://img.shields.io/github/stars/creativecreatorormaybenot/funvas.svg)](https://github.com/creativecreatorormaybenot/funvas) [![Pub version](https://img.shields.io/pub/v/funvas.svg)](https://pub.dev/packages/funvas) [![Twitter Follow](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow&style=social)](https://twitter.com/creativemaybeno)

Flutter package that allows creating canvas animations based on time and math functions.

The name "funvas" is based on Flutter + fun + canvas. Let me know if you have any better ideas :)

## Concept

The idea of the package is to provide an easy way to create custom canvas animations based only
on time and some math functions (sine, cosine, etc.) - like [this one][Twitter].

GIFs to be inserted here (:

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

USAGE to be inserted here (:

See the [example package][example] for a complete example implementation.

[Twitter]: https://twitter.com/creativemaybeno/status/1285343758247178240?s=20
[Dwitter]: https://www.dwitter.net/about 
[example]: https://github.com/creativecreatorormaybenot/funvas/tree/master/example
