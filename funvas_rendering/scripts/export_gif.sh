rm -rf export/animation/
mkdir -p export/animation/
flutter run --dart-define=EXPORT_PATH="$(pwd)/export/"
convert export/animation/*.png gif:- |  gifsicle -O3 --delay=2 --multifile - > export/animation.gif
