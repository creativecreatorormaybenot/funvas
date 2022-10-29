rm -rf export/animation/
mkdir -p export/animation/
rm -rf $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/
flutter run
mv $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/export/animation/* ./export/animation/
convert -verbose -delay 2 export/animation/*.png -loop 0 export/animation.gif
