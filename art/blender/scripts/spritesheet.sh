#!/usr/bin/env bash
if [ "$#" -ne 1 ]; then
    echo "Required output filename."
    exit 1
fi

out_file=$1

# spritesheet
montage \
 -background transparent \
 -tile 8x8 \
 -geometry 128x128 \
 $(ls ./sprites/out/*.png | head -n 64) \
 "./sprites/$out_file.png"

# animated gif
convert \
 -delay 10 \
 -dispose Background \
 "./sprites/$out_file.png" \
 -crop 128x128 \
 -loop 0 \
 +repage \
 "./sprites/$out_file.gif"