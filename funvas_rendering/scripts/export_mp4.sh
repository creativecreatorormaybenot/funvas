rm -rf export/animation/
mkdir -p export/animation/
flutter run --dart-define=EXPORT_PATH="$(pwd)/export/"
ffmpeg -r 50 -f image2 -s 750x750 -i export/animation/%04d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p export/animation.mp4
