#!/bin/bash
# Usage: VO_DIR=lessac OUTNAME=connect4_demo_lessac ./build.sh
set -e
cd "$(dirname "$0")"
PY=../vid-venv/bin/python
OUTNAME=${OUTNAME:-connect4_demo}
export VO_DIR=${VO_DIR:-lessac}
export AUDIO_NAME=$OUTNAME.wav
TOTAL=$($PY -c "import render; print(render.build_timeline()[1])")
CHUNK=$($PY -c "import math; print(math.ceil($TOTAL / 8))")
rm -f out/part_*.mp4
pids=()
for i in 0 1 2 3 4 5 6 7; do
  a=$((i*CHUNK)); b=$(((i+1)*CHUNK))
  $PY render.py --range $a $b out/part_$i.mp4 > out/log_$i.txt 2>&1 &
  pids+=($!)
done
$PY -c "import render; s,t=render.build_timeline(); print(render.build_audio(s,t))"
for p in "${pids[@]}"; do wait $p; done
: > out/parts.txt
for i in 0 1 2 3 4 5 6 7; do echo "file 'part_$i.mp4'" >> out/parts.txt; done
ffmpeg -loglevel error -y -f concat -safe 0 -i out/parts.txt -c copy out/video_only.mp4
ffmpeg -loglevel error -y -i out/video_only.mp4 -i out/$AUDIO_NAME -t $TOTAL -c:v copy -c:a aac -b:a 192k -movflags +faststart out/$OUTNAME.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 out/$OUTNAME.mp4
