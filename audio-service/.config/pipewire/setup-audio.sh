#!/bin/bash

# Create named virtual
pactl load-module module-null-sink sink_name=system_sink sink_properties=device.description="System"
pactl load-module module-null-sink sink_name=browser_sink sink_properties=device.description="Browser"
pactl load-module module-null-sink sink_name=music_sink sink_properties=device.description="Music"
pactl load-module module-null-sink sink_name=game_sink sink_properties=device.description="Game"
pactl load-module module-null-sink sink_name=voice_sink sink_properties=device.description="Voice-Chat"
pactl load-module module-null-sink sink_name=sfx_sink sink_properties=device.description="SFX"
pactl load-module module-null-sink sink_name=aux1_sink sink_properties=device.description="Aux-1"
pactl load-module module-null-sink sink_name=aux2_sink sink_properties=device.description="Aux-2"

# Wait for sinks to appear
sleep 2

# Define your physical output here (check with `pw-link -o`)
OUT_LEFT="alsa_output.pci-0000_02_02.0.analog-stereo:playback_FL"
OUT_RIGHT="alsa_output.pci-0000_02_02.0.analog-stereo:playback_FR"

# Connect monitor outputs of each sink to physical output
pw-link aux1_sink:monitor_FL $OUT_LEFT
pw-link aux1_sink:monitor_FR $OUT_RIGHT

pw-link aux2_sink:monitor_FL $OUT_LEFT
pw-link aux2_sink:monitor_FR $OUT_RIGHT

pw-link browser_sink:monitor_FL $OUT_LEFT
pw-link browser_sink:monitor_FR $OUT_RIGHT

pw-link game_sink:monitor_FL $OUT_LEFT
pw-link game_sink:monitor_FR $OUT_RIGHT

pw-link music_sink:monitor_FL $OUT_LEFT
pw-link music_sink:monitor_FR $OUT_RIGHT

pw-link sfx_sink:monitor_FL $OUT_LEFT
pw-link sfx_sink:monitor_FR $OUT_RIGHT

pw-link system_sink:monitor_FL $OUT_LEFT
pw-link system_sink:monitor_FR $OUT_RIGHT

pw-link voice_sink:monitor_FL $OUT_LEFT
pw-link voice_sink:monitor_FR $OUT_RIGHT
