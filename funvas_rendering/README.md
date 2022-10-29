# funvas_rendering

Package for rendering and exporting funvas animations.

This project contains code for exporting funvas animations to GIFs (and mp4).  
The entrypoints can be found in the `scripts/` directory while the code that renders the animations
and exports them to images lives in the `lib/` directory.

## Exporting animations

You will need [gifsicle] for exporting GIFs. The installation is as easy as running `brew install gifsicle`.
If you are not on macOS, you will need to read through installation guides yourself.
Additionally, you need to have [ImageMagick] to convert PNGs to individual GIFs as gifsicle only
supports GIF input. This can also be as easy as running `brew install imagemagick`.

The script for exporting animations is a **bash script**. If you do not have access to Bash, you
will have to execute the commands manually.

### Usage

You can simply edit the `lib/main.dart` file to adjust the settings of the exporter.  
Then, you want to run one of the scripts. An example execution might look like this:

```sh
bash scripts/export_gif.sh
```

You can configure the following parameters:

* FPS
* Animation duration
* Dimensions
* The funvas to be used :)

The exporter uses a custom Flutter binding to generate the frames. Those will be saved at
`export/<animation name>/<frame number>.gif`. gifsicle will then assemble a GIF from the
frames. Note that you will also need to adjust the bash script (`scripts/export_gif.sh`) to use your
frames (the path) and also your frame rate (the delay is given in hundredths of a second, i.e. the
delay between two frames - you will have to calculate that yourself).

### MP4

The process is essentially the same for mp4, just that the tool used is `ffmpeg`
(`brew install ffmpeg`) and the bash script is `scripts/export_mp4.sh` :)

### Windows

All above explanations and available scripts assume that you are running on macOS.  
In order to export animations on Windows instead, follow the following steps
(tested on Windows 10 Professional 64-bit on a Ryzen 3400G with 16GB of RAM):

1. Download and install [ImageMagick7][ImageMagick].
2. Download gifsicle and extract the executable into the directory you want to use for rendering.
3. Add Windows support using `flutter create --platforms=windows .` in `funvas_rendering`.
4. Generate the `.png` files using `flutter run -d windows` in `funvas_rendering`.
5. Run the following command in a Command Prompt:

```sh
magick "D:\Path\To\Repo\funvas_rendering\export\*.png" gif:- | gifsicle -O3 --delay=2 --multifile - > "D:\Path\To\Repo\funvas_rendering\export\animation.gif"
```

[Twitter]: https://twitter.com/creativemaybeno
[funvas]: https://pub.dev/packages/funvas
[gifsicle]: http://www.lcdf.org/gifsicle
[ImageMagick]: https://imagemagick.org/index.php