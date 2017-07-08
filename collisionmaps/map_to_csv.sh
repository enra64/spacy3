#!/bin/zsh
empty=""
for i in *.map; do
    line=$(sed '9q;d' $i | cut -c 28- | cut -f1 -d'"' )
    filename="${i/.xcf/$empty}"
    filename="${filename/.map/$empty}"
    echo working on $filename
    echo $line > $filename.csv
done
