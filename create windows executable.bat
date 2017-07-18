del spacy3.zip spacy3.exe
7za a -r -tzip -xr!xcf\* -xr!raw\* -xr!.git\* -xr!sounds\audacity\* -x!spacy3.zip -x!spacy3.exe -x!spacy3.apk -x!spacy3.love -x!7za.exe -x!*.sh -x!*.zip.tmp* spacy3.love *
copy /b "C:\Program Files (x86)\LOVE\love.exe"+spacy3.love spacy3.exe
echo "created .love archive and zip and exe"
pause

move spacy3.exe ..\spacy3_distribution\spacy3.exe

cd ..
mkdir spacy3_distribution
move spacy3\spacy3.exe spacy3_distribution\spacy3.exe
robocopy "C:\Program Files (x86)\LOVE" "spacy3_distribution" "license.txt" "love.dll" "lua51.dll" "mpg123.dll" "msvcp120.dll" "msvcr120.dll" "OpenAL32.dll" "SDL2.dll"

echo "created spacy3 distribution folder"
pause

7za a -r -tzip spacy3.zip spacy3_distribution\*
move spacy3\spacy3.love spacy3.love

echo "zipped dist folder"
pause

rmdir /s /q spacy3_distribution
del -r spacy3_distribution