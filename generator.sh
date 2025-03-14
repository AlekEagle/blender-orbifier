#!/bin/bash

INPUT_TEXTURE=$1

OUTPUT_LOCATION="output/$2"

# Make a directory to store our output
mkdir -p $OUTPUT_LOCATION

# Generate our orb video file
blender -y -b sphere.blend -- --texture $INPUT_TEXTURE --output $OUTPUT_LOCATION/orb.mp4

# Generate our gif files
./gif-script.sh $OUTPUT_LOCATION/orb.mp4 $OUTPUT_LOCATION/orb