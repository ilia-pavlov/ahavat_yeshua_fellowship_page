#!/usr/bin/env bash
# Builds phone-friendly copies of gallery photos. Originals are never changed.
#
#   images/<album>/thumbs/<name>.webp   longest side 720px  (album strips)
#   images/<album>/large/<name>.webp    longest side 1800px (full-screen viewer)
#
# Usage: scripts/make-gallery-images.sh [album-folder ...]
#   No arguments = all four albums. Existing copies are skipped unless the
#   original is newer, so it is safe to re-run after adding photos.
# Needs: cwebp (brew install webp) and sips (built into macOS).

set -euo pipefail
cd "$(dirname "$0")/.."

albums=("$@")
if [ ${#albums[@]} -eq 0 ]; then
  albums=(images/main-service images/kids-ministry images/evangelistic-events images/easter-2026)
fi

make_copy() { # src dest max_side quality
  local src=$1 dest=$2 max=$3 q=$4
  [ -f "$dest" ] && [ "$dest" -nt "$src" ] && return
  local w h
  w=$(sips -g pixelWidth "$src" | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$src" | awk '/pixelHeight/{print $2}')
  local resize=()
  if [ "$w" -ge "$h" ] && [ "$w" -gt "$max" ]; then resize=(-resize "$max" 0)
  elif [ "$h" -gt "$w" ] && [ "$h" -gt "$max" ]; then resize=(-resize 0 "$max")
  fi
  cwebp -quiet -q "$q" -metadata none ${resize[@]+"${resize[@]}"} "$src" -o "$dest"
}

for dir in "${albums[@]}"; do
  mkdir -p "$dir/thumbs" "$dir/large"
  for src in "$dir"/*.{jpg,jpeg,JPG,JPEG,png,PNG}; do
    [ -f "$src" ] || continue
    name=$(basename "${src%.*}")
    make_copy "$src" "$dir/thumbs/$name.webp" 720 72
    make_copy "$src" "$dir/large/$name.webp" 1800 80
  done
  echo "$dir: $(ls "$dir/thumbs" | wc -l | tr -d ' ') thumbs, $(ls "$dir/large" | wc -l | tr -d ' ') large"
done
