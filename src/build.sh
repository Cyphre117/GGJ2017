# delete the old build if it was there
rm -r SoundsInADarkRoom.app
rm -r SoundsInADarkRoom.love
rm SoundsInADarkRoom-osx.zip
rm SoundsInADarkRoom-win32.zip

# zip the contents of the src folder (not the folder itself)
zip -9 -r ../distribution/SoundsInADarkRoom.love .

# Grab the love app
cp -R /Applications/love.app/ ../distribution/SoundsInADarkRoom.app/

cd ../distribution

# move the .love file into the app
cp SoundsInADarkRoom.love SoundsInADarkRoom.app/Contents/Resources/

# delete the default plist
rm ../distribution/SoundsInADarkRoom.app/Contents/Info.plist

# insert my new one
cp ../distribution/Info.plist ../distribution/SoundsInADarkRoom.app/Contents/

# zip up the osx build
zip -9 -r SoundsInADarkRoom-osx.zip SoundsInADarkRoom.app/

# cat love.exe and the .love file into one .exe
cat win/love.exe SoundsInADarkRoom.love > win/SoundsInADarkRoom.exe

# GGJ2017/distribution/win
cd win

# put all the required items into the windows zip
zip -9 -r ../SoundsInADarkRoom-win32.zip *.dll *.txt *.exe

# GGJ2017/distribution
cd ..

zip -9 -r SoundsInADarkRoom-release.zip SoundsInADarkRoom-win32.zip SoundsInADarkRoom-osx.zip SoundsInADarkRoom.love HOW-TO-PLAY.md
rm SoundsInADarkRoom-osx.zip
rm SoundsInADarkRoom-win32.zip
rm SoundsInADarkRoom.love
rm -R SoundsInADarkRoom.app

#GGJ2017
cd ..

rm SoundsInADarkRoom-src.zip
rm SoundsInADarkRoom-release.zip

# zip up the source files
zip -r SoundsInADarkRoom-src.zip src/

# grab the release folder
mv distribution/SoundsInADarkRoom-release.zip ./