rm -rf animation
mkdir google_fonts
flutter run
rm animation/_warmup.png
convert -delay 2 animation/*.png -loop 0 animation.gif
