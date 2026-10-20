#!/bin/sh
# Encode the home background video from the untouched source clip.
#
#   design/source_videos/483301_original.mp4  (HEVC 1080x1920 ~60fps, 9.29s)
#     -> assets/videos/483301.mp4             (H.264 1080x1920 60fps, 8.48s)
#
# * Real-time speed: every frame keeps its place on a clean 60fps clock.
# * Seamless loop: the first 0.8s (48 frames) dissolves over the last 0.8s,
#   so the final frame flows into the first (original frames 47 -> 48).
# * H.264 High for hardware decode everywhere (HEVC is patchy on Android),
#   a keyframe every second, moov atom first, no audio (played muted).
#
# Run from the project root: sh design/tools/encode_home_video.sh
set -eu

SRC=design/source_videos/483301_original.mp4
OUT=assets/videos/483301.mp4
FRAMES=$(ffprobe -v error -count_frames -select_streams v:0 \
  -show_entries stream=nb_read_frames -of csv=p=0 "$SRC")
HEAD=48 # 0.8s at 60fps
OFFSET=$(python3 -c "print(round(($FRAMES - 2 * $HEAD) / 60, 6))")

ffmpeg -v error -y -i "$SRC" -filter_complex "\
[0:v]setpts=N/(60*TB),split[a][b];\
[a]trim=start_frame=0:end_frame=$HEAD,setpts=N/(60*TB)[head];\
[b]trim=start_frame=$HEAD,setpts=N/(60*TB)[body];\
[body][head]xfade=transition=fade:duration=0.8:offset=$OFFSET,format=yuv420p[out]" \
  -map "[out]" -an -r 60 \
  -c:v libx264 -preset slower -tune film -crf 22 -maxrate 8M -bufsize 16M \
  -profile:v high -level 4.2 -g 60 -keyint_min 60 -sc_threshold 0 \
  -movflags +faststart "$OUT"

echo "Wrote $OUT"
