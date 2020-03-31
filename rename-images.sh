#!/bin/sh

#
# Shell script for renaming image files according to their meta data dates.
# The files will be copied to a specified directory with new file names.
#
# Arguments:
#   $1  - source directory,
#   $2  - destination directory.
#
# Dependencies:
#   FFmpeg (tested on version 4.0.2)
#


IFS0=$IFS
IFS=$'\n'

if [[ $ == "" || ! -d $2 ]]
then
    echo "Destination directory '$2' doesn't exist!"
    exit 1
fi

for src in $1/*; do
    if [ ! -f $src ]
    then
        echo "File '$src' doesn't exist!"
        continue
    fi

    if [[ $( file $src | grep -Eo image ) == "" ]]
    then
        echo "File '$src' is not an image file!"
        continue
    fi

    meta_date=($(
        mediainfo -f $src | grep 'File last modification date (local)'  \
            | grep -E -o '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}'
    ))

    if [[ $meta_date == "" ]]
    then
        meta_date=$(date -r $src "+%Y-%m-%d %H:%M:%S")
    fi

    meta_date=$(echo $meta_date | sed 's/[: \-]//g')
    dst=$2/IMG_$meta_date.${src##*.}

    if [ -f $dst ]
    then
        echo "File '$dst' already exists!"
        dst_old=$dst
        
        idx=1
        while true
        do
            dst=$2/IMG_"$meta_date"_$idx.${src##*.}
            if [ ! -f $dst ]
            then
                break
            fi
            ((idx++))
        done
        
        echo "Renaming '$dst_old' to '$dst'."
    fi

    echo "Copying '$src' to '$dst'"
    cp $src $dst
done

IFS=$IFS0
