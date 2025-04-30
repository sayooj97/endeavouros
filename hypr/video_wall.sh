#!/bin/bash
while true; do
    for img in ~/Pictures/video_frames/*.png; do
        swww img "$img"
        sleep 0.1  # Adjust speed (higher = slower animation)
    done
done
