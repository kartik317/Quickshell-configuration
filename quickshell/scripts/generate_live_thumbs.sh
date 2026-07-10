#!/usr/bin/env bash

DIR="$1"
THUMBDIR="$HOME/.cache/live_wallpaper_thumbs"
mkdir -p "$THUMBDIR"

# Minimal 1x1 transparent PNG (base64) fallback
PLACEHOLDER_BASE64="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMB/6XdxQAAAABJRU5ErkJggg=="

find "$DIR" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) | sort | while read -r f; do
    base=$(basename "$f")
    ext="${base##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    name="${base%.*}"
    thumb="$THUMBDIR/$name.png"

    # generate thumbnail for video
    if [ "$ext" = "mp4" ] || [ "$ext" = "webm" ] || [ "$ext" = "mkv" ] || [ "$ext" = "mov" ]; then
        # always try to regenerate if file missing or zero-size
        if [ ! -s "$thumb" ]; then
            if command -v ffmpeg >/dev/null 2>&1; then
                ffmpeg -y -loglevel error -ss 00:00:01 -i "$f" -frames:v 1 -vf "scale=640:-1" "$thumb" >/dev/null 2>&1 || true
            fi
        fi
        # if still invalid, try another extraction
        if [ ! -s "$thumb" ] && command -v ffmpeg >/dev/null 2>&1; then
            ffmpeg -y -loglevel error -i "$f" -frames:v 1 "$thumb" >/dev/null 2>&1 || true
        fi
        # validate PNG; if invalid, write placeholder
        if [ ! -s "$thumb" ] || ! file --brief --mime-type "$thumb" 2>/dev/null | grep -qi png; then
            echo "$PLACEHOLDER_BASE64" | base64 -d > "$thumb" 2>/dev/null || (printf '%s' "" > "$thumb")
        fi
    else
        # static image -> create resized png thumbnail (regenerate if missing or zero)
        if [ ! -s "$thumb" ]; then
            if command -v convert >/dev/null 2>&1; then
                convert "$f" -thumbnail 640x480^ -gravity center -extent 640x480 "$thumb" >/dev/null 2>&1 || true
            elif command -v ffmpeg >/dev/null 2>&1; then
                ffmpeg -y -loglevel error -i "$f" -vf "scale=640:-1" "$thumb" >/dev/null 2>&1 || true
            else
                cp "$f" "$thumb" 2>/dev/null || true
            fi
        fi
        if [ ! -s "$thumb" ] || ! file --brief --mime-type "$thumb" 2>/dev/null | grep -qi png; then
            echo "$PLACEHOLDER_BASE64" | base64 -d > "$thumb" 2>/dev/null || (printf '%s' "" > "$thumb")
        fi
    fi

    # always emit the wallpaper path (UI uses this list)
    echo "$f"
done
