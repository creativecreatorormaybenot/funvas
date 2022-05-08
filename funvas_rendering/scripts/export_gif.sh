rm -rf export/animation/
flutter run
convert export/animation/*.png gif:- |  gifsicle -O3 --delay=2 --multifile - > export/animation.gif
