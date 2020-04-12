#!/bin/sh

#
# Encodes all video files with the specified extension (*.avi) to MP4 format.
#


for i in *.avi; do name=${i%.*}; ffmpeg -i "$i" "${name}.mp4" ; done
