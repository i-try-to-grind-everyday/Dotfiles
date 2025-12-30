#!/bin/bash

# Path to your tune
TUNE="$HOME/.Scripts/Notification/tune_1.mp3"

# Get DND state from swaync-client (-D prints current DND state: "true" or "false")
DND_STATE=$(swaync-client -D 2>/dev/null)

# Only play sound if DND is off
if [ "$DND_STATE" = "false" ]; then
    play "$TUNE"
fi

