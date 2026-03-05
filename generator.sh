#!/bin/bash

# Get current directory of the script, following any/all symlinks if necessary
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}" )" )" >/dev/null 2>&1 && pwd )"

# Store all options in an array to be used later
while [[ "$1" == --* ]]; do
  OPTIONS+=("$1")
  shift
done

INPUT_TEXTURE=$1

OUTPUT_LOCATION="output/$2"

# Make a directory to store our output
mkdir -p "$OUTPUT_LOCATION"

# Generate our orb video file
blender -y -b "$DIR/sphere.blend" -- --texture "$INPUT_TEXTURE" --output "$OUTPUT_LOCATION/orb.mp4"

# Generate our gifs and pass the options we stored in the array
"$DIR/gif-script.sh" "${OPTIONS[@]}" "$OUTPUT_LOCATION/orb.mp4" "$OUTPUT_LOCATION/orb"