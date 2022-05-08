rm -rf export/animation/
mkdir -p export/animation/
flutter run
mv $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/export/animation/* ./export/animation/
convert -delay 2 export/animation/*.png -loop 0 export/animation.gif
