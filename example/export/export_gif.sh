rm -rf animation
flutter test --no-sound-null-safety --update-goldens export/export_animation.dart
convert animation/*.png gif:- |  gifsicle -O3 --delay=2 --multifile - > animation.gif
