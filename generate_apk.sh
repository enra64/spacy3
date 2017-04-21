#!/usr/bin/env bash
echo "return function() return true end" > is_touch.lua

# export all the variables
export ANDROID_SDK=/opt/sdk-android
export ANDROID_NDK=/opt/sdk-android/ndk-bundle/
export ANDROID_SWT=/usr/share/java
export ANDROID_HOME=${ANDROID_SDK}
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_NDK

# zip to game.love
zip -qr -9 game.love . -x "xcf/*" -x ".idea/*" -x spacy3.iml -x "out/*" -x .gitignore -x "raw/*" -x *.apk -x ".git/*"

# move the game.love to the love-android folder
mkdir -p /home/arne/Documents/Development/love2d-android-gradle/app/src/main/assets/
mv game.love /home/arne/Documents/Development/love2d-android-gradle/app/src/main/assets/

# move to my love-android folder
cd /home/arne/Documents/Development/love2d-android-gradle/

# DEPLOY
echo "Building now. This might take a while."
./gradlew assembleDebug

cp /home/arne/Documents/Development/love2d-android-gradle/app/build/outputs/apk/app-debug.apk /home/arne/Documents/Development/spacy3/love-android-debug.apk


echo "return function() return false end" > /home/arne/Documents/Development/spacy3/is_touch.lua

# DEPLOY EVEN MORE
adbdevices=$(adb devices)

if [[ $adbdevices == *"ZY3222WWS3"* ]]; then
    echo "Installing on device now. This might also take a while."
    adb install -r /home/arne/Documents/Development/spacy3/love-android-debug.apk
    
    echo "Starting app on device"
    adb shell am start -n org.love2d.android/org.love2d.android.GameActivity
fi
