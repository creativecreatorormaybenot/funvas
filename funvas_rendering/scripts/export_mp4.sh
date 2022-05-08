rm -rf animation
mkdir google_fonts
flutter run export/export_animation.dart
rm animation/_warmup.png
ffmpeg -r 50 -f image2 -s 750x750 -i animation/%04d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation.mp4
