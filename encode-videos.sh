#!/bin/sh

#
# Encodes video files with FFmpeg.
#
# Arguments:
#   $1  - source directory;
#   $2  - destination directory.
#
# Dependencies:
#   ffmpeg version 4.0.2
#


IFS0=$IFS
IFS=$'\n'

if [[ $1 == "" || ! -d $1 ]]
then
    echo "Source directory '$1' doesn't exist!"
    exit 1
fi

if [[ $2 == "" || ! -d $2 ]]
then
    echo "Destination directory '$2' doesn't exist!"
    exit 1
fi

VIDEO_WIDTH=1280
VIDEO_HEIGHT=720
VIDEO_ROTATION=90
VIDEO_EXTENSION=.mp4

for src in $1/*; do
    if [ ! -f $src ]
    then
        echo "File '$src' doesn't exist!"
        continue
    fi

    WIDTH=$VIDEO_WIDTH
    HEIGHT=$VIDEO_HEIGHT

    res=$( ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 $src )
    res=( $( echo $res | grep -E -o '(\d+)' ) )
    width=${res[0]}
    height=${res[1]}

    rot=$( ffprobe -v error -select_streams v:0 -show_entries stream_tags=rotate -of csv=s=x:p=0 $src )

    if [[ $rot -eq $VIDEO_ROTATION ]]
    then
        tmp=$width
        width=$height
        height=$tmp

        tmp=$WIDTH
        WIDTH=$HEIGHT
        HEIGHT=$tmp
    fi

    if [[ $width -gt $WIDTH ]]
    then
        width=$WIDTH
    fi

    if [[ $height -gt $HEIGHT ]]
    then
        height=$HEIGHT
    fi

    dst0=${src%.*}
    dst=$2/${dst0##*/}$VIDEO_EXTENSION

    if [ -f $dst ]
    then
        dst_old=$dst
        
        idx=1
        while true
        do
            dst=$2/${dst0##*/}_"$idx"$VIDEO_EXTENSION
            if [ ! -f $dst ]
            then
                break
            fi
            ((idx++))
        done
    fi

    ffmpeg -i $src -vf scale=$width:$height $dst -hide_banner
done


IFS=$IFS0
