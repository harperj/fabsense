#!/bin/bash
ffmpeg -i $1.avi -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 -vf scale=-1:480 -movflags faststart -b:a 128k $1.webm