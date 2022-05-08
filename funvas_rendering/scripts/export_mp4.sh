rm -rf export/animation/
mkdir -p export/animation/
flutter run
mv $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/export/animation/* ./export/animation/
ffmpeg -r 50 -f image2 -s 750x750 -i export/animation/%04d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p export/animation.mp4
