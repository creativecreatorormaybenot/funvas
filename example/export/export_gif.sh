rm -rf animation
flutter test --update-goldens export/export_animation.dart
convert animation/*.png gif:- |  gifsicle --delay=20 --multifile - > animation.gif