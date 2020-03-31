#!/bin/sh

#
# Encodes all video files with the specified extension (*.avi) to MP4 format.
#

# https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash

for i in *.avi; do name=${i%.*}; ffmpeg -i "$i" "${name}.mp4" ; done
