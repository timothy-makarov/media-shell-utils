
#
# Encodes the video files with FFmpeg.
#
# Arguments:
#   $1  - source directory
#
# Dependencies:
#   ffmpeg version 4.0.2
#


IFS0=$IFS
IFS=$'\n'

if [[ $1 == "" || ! -d $1 ]]
then
    echo "Directory '$1' doesn't exist!"
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
    dst=$1/${dst0##*/}_E$VIDEO_EXTENSION

    if [ -f $dst ]
    then
        dst_old=$dst
        
        idx=1
        while true
        do
            dst=$1/${dst0##*/}_E_"$idx"$VIDEO_EXTENSION
            if [ ! -f $dst ]
            then
                break
            fi
            ((idx++))
        done
    fi

    ffmpeg  -i $src \
            -vcodec libx264 \
            -acodec aac \
            -vf scale=$width:$height \
            -hide_banner \
            $dst
done


IFS=$IFS0
