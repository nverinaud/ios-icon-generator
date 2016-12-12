#!/bin/bash
#
# Copyright (C) 2014 Wenva <lvyexuwenfa100@126.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

SRC_FILE="$1"
DST_PATH="$2"

VERSION=1.0.1

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}INFO${normal}] $1"
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 srcfile dstpath [--skip-itunes-artwork]

DESCRIPTION:
    This script aim to generate ios app Icons easier and simply.

    srcfile    The source png image. Preferably above 1024x1024
    dstpath    The destination path where the Icons generate to.

    --skip-itunes-artwork   (Optional) Skip generating iTunes Artwork 
                            (useful if you only want to generate app Icon)

    This script is depend on ImageMagick. So you must install ImageMagick first
    You can use 'sudo brew install ImageMagick' to install it

AUTHOR:
    Pawpaw<lvyexuwenfa100@126.com>

LICENSE:
    This script follow MIT license.

EXAMPLE:
    $0 1024.png ~/123
EOF
}

read -r -d '\0' CONTENTS_JSON << EOM
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-Small.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-Small@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-Small@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-Small-40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-Small-40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "57x57",
      "idiom" : "iphone",
      "filename" : "Icon.png",
      "scale" : "1x"
    },
    {
      "size" : "57x57",
      "idiom" : "iphone",
      "filename" : "Icon@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-20.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-Small.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-Small@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-Small-40.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-Small-40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "50x50",
      "idiom" : "ipad",
      "filename" : "Icon-Small-50.png",
      "scale" : "1x"
    },
    {
      "size" : "50x50",
      "idiom" : "ipad",
      "filename" : "Icon-Small-50@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "72x72",
      "idiom" : "ipad",
      "filename" : "Icon-72.png",
      "scale" : "1x"
    },
    {
      "size" : "72x72",
      "idiom" : "ipad",
      "filename" : "Icon-72@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-76.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-83.5@2x.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}\0
EOM

# Check ImageMagick
command -v convert >/dev/null 2>&1 || { error >&2 "The ImageMagick is not installed. Please use brew to install it first."; exit -1; }

# Check param
if [[ $# -lt 2 ]];then
    usage
    exit -1
fi

SKIP_ARTWORK=false

if [ $# -gt 2 ];then
    if [ "$3" == "--skip-itunes-artwork" ];then
        SKIP_ARTWORK=true
    fi
fi

# Check dst path whether exist.
if [ ! -d "$DST_PATH" ];then
    mkdir -p "$DST_PATH"
fi

# Generate, refer to: https://developer.apple.com/library/ios/qa/qa1686/_index.html

if [ $SKIP_ARTWORK == false ];then
    info 'Generate iTunesArtwork.png ...'
    convert "$SRC_FILE" -resize 512x512 "$DST_PATH/iTunesArtwork.png"
    info 'Generate iTunesArtwork@2x.png ...'
    convert "$SRC_FILE" -resize 1024x1024 "$DST_PATH/iTunesArtwork@2x.png"
else
    info 'Skipping iTunesArtwork'
fi

info 'Generate Icon-Small.png ...'
convert "$SRC_FILE" -resize 29x29 "$DST_PATH/Icon-Small.png"
info 'Generate Icon-Small@2x.png ...'
convert "$SRC_FILE" -resize 58x58 "$DST_PATH/Icon-Small@2x.png"
info 'Generate Icon-Small@3x.png ...'
convert "$SRC_FILE" -resize 87x87 "$DST_PATH/Icon-Small@3x.png"

info 'Generate Icon-Small-40.png ...'
convert "$SRC_FILE" -resize 40x40 "$DST_PATH/Icon-Small-40.png"
info 'Generate Icon-Small-40@2x.png ...'
convert "$SRC_FILE" -resize 80x80 "$DST_PATH/Icon-Small-40@2x.png"
info 'Generate Icon-Small-40@3x.png ...'
convert "$SRC_FILE" -resize 120x120 "$DST_PATH/Icon-Small-40@3x.png"

info 'Generate Icon-60@2x.png ...'
convert "$SRC_FILE" -resize 120x120 "$DST_PATH/Icon-60@2x.png"
info 'Generate Icon-60@3x.png ...'
convert "$SRC_FILE" -resize 180x180 "$DST_PATH/Icon-60@3x.png"

info 'Generate Icon-76.png ...'
convert "$SRC_FILE" -resize 76x76 "$DST_PATH/Icon-76.png"
info 'Generate Icon-76@2x.png ...'
convert "$SRC_FILE" -resize 152x152 "$DST_PATH/Icon-76@2x.png"

info 'Generate Icon-83.5@2x.png ...'
convert "$SRC_FILE" -resize 167x167 "$DST_PATH/Icon-83.5@2x.png"

info 'Generate Icon.png ...'
convert "$SRC_FILE" -resize 57x57 "$DST_PATH/Icon.png"
info 'Generate Icon@2x.png ...'
convert "$SRC_FILE" -resize 114x114 "$DST_PATH/Icon@2x.png"

info 'Generate Icon-72.png ...'
convert "$SRC_FILE" -resize 72x72 "$DST_PATH/Icon-72.png"
info 'Generate Icon-72@2x.png ...'
convert "$SRC_FILE" -resize 144x144 "$DST_PATH/Icon-72@2x.png"

info 'Generate Icon-Small-50.png ...'
convert "$SRC_FILE" -resize 50x50 "$DST_PATH/Icon-Small-50.png"
info 'Generate Icon-Small-50@2x.png ...'
convert "$SRC_FILE" -resize 100x100 "$DST_PATH/Icon-Small-50@2x.png"

info 'Generate Icon-20.png ...'
convert "$SRC_FILE" -resize 20x20 "$DST_PATH/Icon-20.png"
info 'Generate Icon-20@2x.png ...'
convert "$SRC_FILE" -resize 40x40 "$DST_PATH/Icon-20@2x.png"
info 'Generate Icon-20@3x.png ...'
convert "$SRC_FILE" -resize 60x60 "$DST_PATH/Icon-20@3x.png"

info "Generate Contents.json ..."
echo $CONTENTS_JSON > "$DST_PATH/Contents.json"

info 'Generate Done.'
