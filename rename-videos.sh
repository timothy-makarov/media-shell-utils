#!/bin/sh

#
# Shell script for renaming video files according to their meta data dates.
# The files will be copied to a specified directory with new file names.
#
# Arguments:
#   $1  - source directory,
#   $2  - destination directory.
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

if [[ $2 == "" || ! -d $2 ]]
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
    dst=$2/MOV_$meta_date.${src##*.}

    if [ -f $dst ]
    then
        echo "File '$dst' already exists!"
        dst_old=$dst
        
        idx=1
        while true
        do
            dst=$2/MOV_"$meta_date"_$idx.${src##*.}
            if [ ! -f $dst ]
            then
                break
            fi
            ((idx++))
        done
        
        echo "Renaming '$dst_old' to '$dst'."
    fi

    echo "Copying '$src' to '$dst'"
    cp -p $src $dst
done

IFS=$IFS0
