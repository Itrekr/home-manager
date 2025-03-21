#!/bin/bash

# Path to the temporary screenshot file
screenshot_path="/tmp/screenshot.png"

# Path to the blurred screenshot file
blurred_screenshot_path="/tmp/blurred_screenshot.png"

# Path to the overlay image
#overlay_path="$HOME/.config/i3/redacted.png"
overlay_path="$HOME/.config/i3/alex.png"

# Path to the final output file
output_path="/tmp/screensaver.png"

# Take a screenshot and save it to /tmp/screenshot.png
scrot -o "$screenshot_path"

# Add a blur effect to the screenshot
convert "$screenshot_path" -blur 0x3 "$screenshot_path"

# Get dimensions of the background (screenshot)
bg_width=$(identify -format "%w" "$screenshot_path")
bg_height=$(identify -format "%h" "$screenshot_path")

# Get dimensions of the overlay (chains.png)
overlay_width=$(identify -format "%w" "$overlay_path")
overlay_height=$(identify -format "%h" "$overlay_path")

# Calculate the position to center the overlay
x_offset=$(( (bg_width - overlay_width) / 2 ))
y_offset=$(( (bg_height - overlay_height) / 2 ))

# Overlay chains.png onto the blurred screenshot at the calculated position and save it as /tmp/screensaver.png
convert "$screenshot_path" "$overlay_path" -geometry +${x_offset}+${y_offset} -composite "$output_path"

# Lock the screen using i3lock and the final image
i3lock -i "$output_path"
