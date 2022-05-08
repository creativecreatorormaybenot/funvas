rm -rf export/animation/
mkdir -p export/animation/
flutter run --dart-define=EXPORT_PATH="$(pwd)/export/"
convert -delay 2 export/animation/*.png -loop 0 export/animation.gif
