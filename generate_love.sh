#!/usr/bin/env bash

# zip to game.love
zip -qr -9 spacy3.love . -x "xcf/*" -x ".idea/*" -x "sounds/audacity/*" -x spacy3.iml -x "out/*" -x .gitignore -x "raw/*" -x *.apk -x ".git/*"
