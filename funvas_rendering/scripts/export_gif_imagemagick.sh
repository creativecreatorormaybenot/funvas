rm -rf animation
mkdir google_fonts
flutter run export/export_animation.dart
rm animation/_warmup.png
convert -delay 2 animation/*.png -loop 0 animation.gif
