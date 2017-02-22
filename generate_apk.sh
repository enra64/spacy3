#!/usr/bin/env bash
echo "return function() return true end" > is_touch.lua

# export all the variables
export ANDROID_SDK=/opt/sdk-android
export ANDROID_NDK=/home/arne/Programs/ndk-android/
export ANDROID_SWT=/usr/share/java
export ANDROID_HOME=${ANDROID_SDK}
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_NDK

# zip to game.love
zip -qr -9 game.love . -x "xcf/*" -x ".idea/*" -x spacy3.iml -x "out/*" -x .gitignore -x "raw/*" -x *.apk

# move the game.love to the love-android folder
mkdir -p /home/arne/Programs/love-android-sdl2/assets
mv game.love /home/arne/Programs/love-android-sdl2/assets/

# move to my love-android folder
cd /home/arne/Programs/love-android-sdl2/

# DEPLOY
echo "Building now. This might take a while."
ant debug -quiet

cp /home/arne/Programs/love-android-sdl2/bin/love-android-debug.apk /home/arne/Documents/Development/spacy3/love-android-debug.apk


echo "return function() return false end" > /home/arne/Documents/Development/spacy3/is_touch.lua

# DEPLOY EVEN MORE
adbdevices=$(adb devices)

if [[ $adbdevices == *"0c6f31ce541a0b8a"* ]]; then
    echo "Installing on device now. This might also take a while."
    adb install -r /home/arne/Documents/Development/spacy3/love-android-debug.apk
fi