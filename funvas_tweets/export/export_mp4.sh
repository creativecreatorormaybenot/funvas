rm -rf animation
flutter test --update-goldens export/export_animation.dart
ffmpeg -r 50 -f image2 -s 750x750 -i animation/%04d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation.mp4
