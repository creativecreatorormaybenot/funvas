rm -rf export/animation/
mkdir -p export/animation/
flutter run
convert -delay 2 export/animation/*.png -loop 0 export/animation.gif
