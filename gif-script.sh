#!/bin/bash
INPUT_FILE=$1

OUTPUT_FILE=$2

bruh=1
ffmpeg -i $INPUT_FILE -i alpha.png -filter_complex "[0:v][1:v]alphamerge,split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "$OUTPUT_FILE-original.gif"
ffmpeg -i $INPUT_FILE -i alpha.png -filter_complex "[0:v][1:v]alphamerge,scale=256:256,split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "$OUTPUT_FILE-256x256.gif"
ffmpeg -i $INPUT_FILE -i alpha.png -filter_complex "[0:v][1:v]alphamerge,scale=71:71,split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "$OUTPUT_FILE-71x71.gif"
