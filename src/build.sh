# delete the old build if it was there
rm -r ../distribution/SoundsInADarkRoom.app

# zip the contents of the src folder (not the folder itself)
zip -9 -r ../distribution/SoundsInADarkRoom.love .

# Grab the love app
cp -R /Applications/love.app/ ../distribution/SoundsInADarkRoom.app/

# move the .love file into the app
mv ../distribution/SoundsInADarkRoom.love ../distribution/SoundsInADarkRoom.app/Contents/Resources/

# delete the default plist
rm ../distribution/SoundsInADarkRoom.app/Contents/Info.plist

# insert my new one
cp ../distribution/Info.plist ../distribution/SoundsInADarkRoom.app/Contents/