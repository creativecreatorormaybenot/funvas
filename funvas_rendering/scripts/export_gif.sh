rm -rf export/animation/
mkdir -p export/animation/
rm -rf $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/
flutter run
mv $HOME/Library/Containers/creativemaybeno.funvasRendering/Data/export/animation/* ./export/animation/
convert export/animation/*.png gif:- |  gifsicle -O3 --delay=2 --multifile - > export/animation.gif
