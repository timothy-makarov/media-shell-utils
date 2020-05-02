#!/usr/bin/env python3


import os
import subprocess
import sys


EXTENSIONS = [
    '.mov'
]

TARGET_SUF = '_E'
TARGET_EXT = '.MP4'


if(len(sys.argv) < 2):
    sys.exit('Directory argument is misssing!')

if(not os.path.exists(sys.argv[1])):
    sys.exit('Directory does not exist: {}'.format(sys.argv[1]))


for root, _, files in os.walk(sys.argv[1]):
    for fn in files:
        file_name = os.path.join(root, fn)
        fn_woext, extension = os.path.splitext(file_name)
        if (extension.lower() not in EXTENSIONS):
            continue
        fn_out = '{}{}{}'.format(fn_woext, TARGET_SUF, TARGET_EXT)
        if(os.path.exists(fn_out)):
            print('File exists: {}'.format(fn_out))
            continue
        print('Encoding \"{}\" to \"{}\"'.format(file_name, fn_out))
        subprocess.run(
            ['ffmpeg', '-i', file_name, fn_out],
            capture_output=True
        )
