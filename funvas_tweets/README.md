# funvas_tweets

Collection of [`funvas`][funvas] animations tweeted [@creativemaybeno][Twitter].  
You can find all of them in the timeline :)

Additionally, this project contains code for exporting funvas animations to GIFs (and mp4).

## Exporting animations

You will need [gifsicle] for this. The installation is as easy as running `brew install gifsicle`.
If you are not on macOS, you will need to read through installation guides yourself.
Additionally, you need to have [ImageMagick] to convert PNGs to individual GIFs as gifsicle only
supports GIF input. This can also be as easy as using `brew install imagemagick`.

The script for exporting animations is a **bash script**. If you do not have access to Bash, you
will have to execute the commands manually.

### Usage

You can simply edit the `export/export_animation.dart` file to adjust the settings of the exporter.

You can configure the following parameters:

* FPS
* Animation duration
* Dimensions
* The funvas to be used :)

The exporter uses `flutter_test` and its **goldens files** to generate the frames. Those will be
saved at `export/<animation name>/<frame number>.gif`. gifsicle will then assemble a GIF from the
frames. Note that you will also need to adjust the bash script (`export/export_gif.sh`) to use your
frames (the path) and also your frame rate (the delay is given in hundredths of a second, i.e. the
delay between two frames - you will have to calculate that yourself).

### MP4

The process is essentially the same for mp4, just that the tool used is `ffmpeg`
(`brew install ffmpeg`) and the bash script is `export/export_mp4.sh` :)

[Twitter]: https://twitter.com/creativemaybeno
[funvas]: https://pub.dev/packages/funvas
[gifsicle]: http://www.lcdf.org/gifsicle
[ImageMagick]: https://imagemagick.org/index.php
