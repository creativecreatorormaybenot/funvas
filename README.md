# funvas [![Pub version][pub shield]][pub] [![gallery badge]][gallery] [![Twitter Follow][twitter badge]][twitter]

Flutter package that allows creating canvas animations based on time and math (mostly trigonometric)
functions.

The name "funvas" is based on Flutter + fun + canvas. Let me know if you have any better ideas :)

<a target="_blank" href="https://twitter.com/creativemaybeno/status/1328261273922973696?s=20"><img src="https://user-images.githubusercontent.com/19204050/143094392-7be15fd8-dd09-40a0-a9b2-137b3605e0e5.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1327309901270560769?s=20"><img src="https://user-images.githubusercontent.com/19204050/143094636-1c60aa9d-03bf-4f3a-896e-d645bf55fb1b.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1377705763402039303?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479453-b9dd2480-947e-11eb-88b6-4ef3835e0a29.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1360867891906830336?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479456-bfd30580-947e-11eb-9a3a-f807299a289a.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1346101868079042561?s=20"><img src="https://user-images.githubusercontent.com/19204050/143095262-3bc4678c-e68d-4120-b4b0-c362fcf36fb2.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1349343188247404548?s=20"><img src="https://user-images.githubusercontent.com/19204050/143095301-cee78b4a-7c23-41a7-afe4-51b483ff8716.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1369749942080839680?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479483-e8f39600-947e-11eb-858b-ec3fe980f2b2.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1370328227479191553?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479485-ec871d00-947e-11eb-863b-4dac2a92c6e4.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1350085831550148611?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479488-f01aa400-947e-11eb-81c4-e4394ec20b01.gif" width="49%"></a>
<a target="_blank" href="https://twitter.com/creativemaybeno/status/1364560611435307008?s=20"><img src="https://user-images.githubusercontent.com/19204050/113479491-f1e46780-947e-11eb-9bb2-f43748651700.gif" width="49%"></a>

## Gallery [![gallery badge]][gallery]

I share my funvas creations [on Twitter][twitter] and I have also created a [live demo][gallery],
a gallery that allows you to explore some of the animations running right in Flutter web :)

## Community projects

Here are some awesome community projects made using the [`funvas` package][pub] to create some 🔥✨

* **[Square Shooter](https://github.com/namzug16/square-shooter)** game by [namzug16](https://github.com/namzug16)

### Repo structure

This repo currently contains the following packages:

| Package                                                                                          | Contents                                                                                                                                                                                         |
| :----------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`funvas`](https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas)                 | The actual `funvas` Flutter package that is also hosted on Pub. Both `funvas_tweets` and `funvas_gallery` depend on this package. It contains the basic widget for displaying funvas animations. |
| [`funvas_gallery`](https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas_gallery) | Collection of funvas animations I created and shared [on Twitter][twitter]. The package also contains the code I use to export my animations to GIF and mp4.                                     |
| [`funvas_tweets`](https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas_tweets)   | Flutter web app (gallery) showcasing a selection of `funvas_tweets` funvas animations that can be reached at [funvas.creativemaybeno.dev][gallery].                                              |
| [`open_simplex_2`](https://github.com/creativecreatorormaybenot/funvas/tree/main/open_simplex_2) | Package that makes OpenSimplex2 noise generation available to everyone in Dart :) I use this for my own funvas animations (`funvas_tweets`) but it is also hosted for anyone to use on Pub.      |

### Inspiration

The whole concept is *inspired by Dwitter* ([check it out][dtwitter]). That is mainly the way the
API is built. These kinds of animations (especially in GIF form) can be found in many communities,
e.g. in [processing] (and with that p5.js).

[twitter]: https://twitter.com/creativemaybeno
[twitter badge]: https://img.shields.io/twitter/follow/creativemaybeno?label=Follow&style=social
[dtwitter]: https://www.dwitter.net/about
[processing]: https://processing.org
[gallery]: https://funvas.creativemaybeno.dev
[gallery badge]: https://img.shields.io/badge/funvas-gallery-yellow
[funvas]: https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas
[funvas_tweets]: https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas_tweets
[funvas_gallery]: https://github.com/creativecreatorormaybenot/funvas/tree/main/funvas_gallery
[pub]: https://pub.dev/packages/funvas
[pub shield]: https://img.shields.io/pub/v/funvas.svg
