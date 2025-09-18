#!/bin/bash

echo "Resetting virtual sinks..."

# List of sink names to remove
sinks=(
  aux1_sink
  aux2_sink
  browser_sink
  game_sink
  music_sink
  sfx_sink
  system_sink
  voice_sink
)

# Unload all null sinks that match
for sink in "${sinks[@]}"; do
  module_id=$(pactl list short modules | grep "sink_name=$sink" | cut -f1)
  if [ -n "$module_id" ]; then
    echo "Unloading $sink (module $module_id)"
    pactl unload-module "$module_id"
  else
    echo "Sink $sink not found, skipping."
  fi
done

echo "✅ All virtual sinks removed."
