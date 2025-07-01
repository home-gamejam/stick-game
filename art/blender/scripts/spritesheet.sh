#!/usr/bin/env bash
#
# spritesheet.sh
#
# Generates a 64x64 spritesheet and animated GIF from up to 64 PNG images in ./sprites/out/.
#
# Usage: ./spritesheet.sh <output_name>
#   - Creates ./sprites/<output_name>.png (spritesheet)
#   - Creates ./sprites/<output_name>.gif (animated GIF)
#
# Requires ImageMagick (montage, convert).

if [ "$#" -ne 1 ]; then
    echo "Required output filename."
    exit 1
fi

out_file=$1

# spritesheet
montage \
 -background transparent \
 -tile 8x8 \
 -geometry 64x64 \
 $(ls ./sprites/out/*.png | head -n 64) \
 "./sprites/$out_file.png"

# animated gif
convert \
 -delay 10 \
 -dispose Background \
 "./sprites/$out_file.png" \
 -crop 64x64 \
 -loop 0 \
 +repage \
 "./sprites/$out_file.gif"