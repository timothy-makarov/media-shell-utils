#!/bin/sh

#
# Renames video and image files according to their meta data information.
#
# Arguments:
#   $1 - source directory.
#
# Dependencies:
#   ffprobe version 4.0.2
#


IFS0=$IFS
IFS=$'\n'

if [[ $1 == "" || ! -d $1 ]]
then
    echo "Source directory '$1' doesn't exist!"
    exit 1
fi

for src in $1/*; do
    if [ ! -f $src ]
    then
        echo "File '$src' doesn't exist!"
        continue
    fi

    meta_date=(                                                                                \
        $(                                                                                     \
            ffprobe -v quiet $src -print_format flat -show_entries format_tags=creation_time   \
                | grep -E -o '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}'                             \
        )                                                                                      \
    )                                                                                          \

    if [[ $meta_date == "" ]]
    then
        meta_date=$(date -r $src "+%Y-%m-%dT%H:%M:%S")
    fi

    meta_date=$(echo $meta_date | sed 's/[:T\-]//g')
    dst=$1/IMG_$meta_date.${src##*.}

    if [ -f $dst ]
    then
        dst_old=$dst
        
        idx=1
        while true
        do
            dst=$1/IMG_"$meta_date"_$idx.${src##*.}
            if [ ! -f $dst ]
            then
                break
            fi
            ((idx++))
        done

    fi

    echo "Renaming '$src' to '$dst'"
    cp -p $src $dst
    rm -f $src
done

IFS=$IFS0
