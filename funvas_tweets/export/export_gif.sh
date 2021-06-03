rm -rf animation
mkdir google_fonts
flutter test --update-goldens export_animation.dart
rm animation/_warmup.png
convert animation/*.png gif:- |  gifsicle -O3 --delay=2 --multifile - > animation.gif
