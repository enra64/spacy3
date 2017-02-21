echo TOUCH > build_state

# export all the variables
export ANDROID_SDK=/opt/sdk-android
export ANDROID_NDK=/home/arne/Programs/ndk-android/
export ANDROID_SWT=/usr/share/java
export ANDROID_HOME=${ANDROID_SDK}
export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_NDK

# zip to game.love
zip -qr -9 game.love . -x "xcf/*" -x ".idea/*" -x spacy3.iml -x "out/*" -x .gitignore -x "raw/*"

# move the game.love to the love-android folder
mkdir -p /home/arne/Programs/love-android-sdl2/assets
mv game.love /home/arne/Programs/love-android-sdl2/assets/

# move to my love-android folder
cd /home/arne/Programs/love-android-sdl2/

# DEPLOY
ant debug

cp /home/arne/Programs/love-android-sdl2/bin/love-android-debug.apk /home/arne/Documents/Development/spacy3/love-android-debug.apk

echo NO_TOUCH > build_state
