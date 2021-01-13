# funvas [![Pub version](https://img.shields.io/pub/v/funvas.svg)](https://pub.dev/packages/funvas) [![Twitter Follow](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow&style=social)](https://twitter.com/creativemaybeno)

Flutter package that allows creating canvas animations based on time and math (mostly trigonometric)
functions.

The name "funvas" is based on Flutter + fun + canvas. Let me know if you have any better ideas :)

<p float="left" style="margin:0">
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1328261273922973696?s=20"><img src="https://s8.gifyu.com/images/animation8709ccbbf7b20e6e.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1327309901270560769?s=20"><img src="https://s8.gifyu.com/images/animation8709ccbbf7b20e6f.gif" width="49%"></a>
</p>
<p float="left">
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1346101868079042561?s=20"><img src="https://s2.gifyu.com/images/animation053c9f614aad68ef.gif" width="49%"></a>
<a target="_blank" href="TODO"><img src="https://s2.gifyu.com/images/animationbfc096a486621405.gif" width="49%"></a>
</p>

## [Demo][demo]

I share my funvas creations [on Twitter][Twitter] and I have also create a [live demo][demo] that
allows you to see the animations running right in Flutter web :)

### Repo structure

This repo currently contains the following packages:

* [`funvas`][funvas], which is the actual `funvas` Flutter package that is also hosted on Pub.
  Both `funvas_tweets` and `funvas_demo` (+ the `example` package inside of `funvas`) depend on this
  package. It contains the basic widget for displaying funvas animations.
* [`funvas_tweets`][funvas_tweets] is a collection of funvas animations I created and shared
  [on Twitter][Twitter]. The package also contains the code I use to export my animations to GIF.
* [`funvas_demo`][funvas_demo] is a Flutter web app showcasing some funvas animations that can be 
  reached at [funvas.creativemaybeno.dev][demo]. It consists of a selection of funvas animations
  from the `funvas_tweets` package. Not all animations are included because some of them might not
  perform well enough in a live demo :)

### Inspiration

The whole concept is *inspired by Dwitter* ([check it out][Dwitter]). That is mainly the way the
API is built. These kinds of animations (especially in GIF form) can be found in many communities,
e.g. in [Processing] (and with that p5.js). 

[Twitter]: https://twitter.com/creativemaybeno
[Dwitter]: https://www.dwitter.net/about
[Processing]: https://processing.org
[demo]: https://funvas.creativemaybeno.dev
[funvas]: https://github.com/creativecreatorormaybenot/funvas/tree/master/funvas
[funvas_tweets]: https://github.com/creativecreatorormaybenot/funvas/tree/master/funvas_tweets
[funvas_demo]: https://github.com/creativecreatorormaybenot/funvas/tree/master/funvas_demo
