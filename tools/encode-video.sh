#!/bin/sh
# Compress a video for the site and grab a poster frame.
#
#   tools/encode-video.sh <input> <output.mp4> [max-height] [--keep-audio]
#
# Writes <output.mp4> plus <output>.jpg (first frame, shown before playback).
# Defaults: max height 960 (reel tiles are ~320px wide, so this stays sharp on
# retina screens) and audio stripped. Pass --keep-audio for clips where tapping
# for sound should do something.
set -e

in="$1"
out="$2"
maxh="${3:-960}"
audio="-an"
[ "$4" = "--keep-audio" ] && audio="-c:a aac -b:a 96k"

if [ -z "$in" ] || [ -z "$out" ]; then
    echo "usage: $0 <input> <output.mp4> [max-height] [--keep-audio]" >&2
    exit 1
fi

# H.264 (plays everywhere), CRF 28 by default (quality-targeted compression; higher = smaller,
# override with e.g. CRF=26 tools/encode-video.sh ...),
# yuv420p for Safari/iOS, max 30fps (60fps phone footage doubles the size for little gain),
# faststart so playback begins before the whole file downloads.
ffmpeg -y -v error -i "$in" \
    -vf "scale=-2:'min($maxh,ih)'" \
    -fpsmax 30 -c:v libx264 -preset slow -crf "${CRF:-28}" -profile:v high -pix_fmt yuv420p \
    $audio -movflags +faststart \
    "$out"

ffmpeg -y -v error -i "$out" -frames:v 1 -q:v 4 "${out%.*}.jpg"

ls -lh "$in" "$out" "${out%.*}.jpg" | awk '{print $5, $9}'
