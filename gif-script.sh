#!/bin/bash
INPUT_FILE=""

OUTPUT_BASENAME=""

SIZES=(
  "original"
  "256"
  "71"
)

NO_SUFFIX=0

helpMsg() {
  echo "Converts orbs to gifs with alpha channel. By default, it generates three sizes: original, 256x256, and 71x71."
  echo "Usage: $0 [OPTIONS] <INPUT_FILE> <OUTPUT_BASENAME>"
  echo "Options:"
  echo "  --no-default-sizes    Do not generate default sizes (original, 256x256, 71x71)"
  echo "  --size SIZE           Add a custom size (e.g., --size 128) to the output pipeline. Can be used multiple times, maximum is 2048, use keyword 'original' for original size."
  echo "  --no-suffix           Do not add size suffix to output files. This can only be used if there is exactly one size specified."
  echo "  --help                 Show this help message and exit"
  echo ""
  echo "Input file should be a video output by blender running the sphere.blend file. Output basename is the name of the output file without extension, as the script will generate multiple files with different sizes. For example, if the output basename is 'orb', the script will generate 'orb-original.gif', 'orb-256x256.gif', and 'orb-71x71.gif'."
}

processGif() {
  local input_file="$1"
  local output_file="$2"
  local size="$3"
  local no_suffix="$4"

  if [ "$size" == "original" ]; then
    if [ "$no_suffix" -eq 1 ]; then
      ffmpeg -i "$input_file" -i "$DIR/alpha.png" -filter_complex "[0:v][1:v]alphamerge,split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "${output_file}.gif"
    else
      ffmpeg -i "$input_file" -i "$DIR/alpha.png" -filter_complex "[0:v][1:v]alphamerge,split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "${output_file}-original.gif"
    fi
  else
    if [ "$no_suffix" -eq 1 ]; then
      ffmpeg -i "$input_file" -i "$DIR/alpha.png" -filter_complex "[0:v][1:v]alphamerge,scale=${size}:${size},split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "${output_file}.gif"
    else
      ffmpeg -i "$input_file" -i "$DIR/alpha.png" -filter_complex "[0:v][1:v]alphamerge,scale=${size}:${size},split[v0][v1];[v0]palettegen[p];[v1][p]paletteuse" "${output_file}-${size}x${size}.gif"
    fi
  fi
}

if [ "$#" -eq 0 ]; then
  helpMsg
  exit 0
fi

# Iterate through arguments and parse options
while [[ "$1" == --* ]]; do
  case "$1" in
    --no-default-sizes)
      SIZES=()
      shift
      ;;
    --size)
      if [[ -n "$2" ]]; then
        if [[ "$2" != "original" && ! "$2" =~ ^[0-9]+$ ]]; then
          echo "Error: Invalid size '$2'. Size must be a positive integer or 'original'."
          exit 1
        fi
        if [[ "$2" != "original" && "$2" -gt 1920 ]]; then
          echo "Error: Size '$2' exceeds the maximum allowed size of 1920."
          exit 1
        fi
        if [[ "$2" -eq 2048 ]]; then
          SIZES+=("original")
          shift 2
          continue
        fi
        SIZES+=("$2")
        shift 2
      else
        echo "Error: --size option requires an argument."
        exit 1
      fi
      ;;
    --no-suffix)
      NO_SUFFIX=1
      shift
      ;;
    --help)
      helpMsg
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      helpMsg
      exit 1
      ;;
  esac
done

# Check if more than one size is specified with --no-suffix
if [ "$NO_SUFFIX" -eq 1 ] && [ "${#SIZES[@]}" -gt 1 ]; then
  echo "Error: --no-suffix option cannot be used when multiple sizes are specified."
  exit 1
fi

# Check if at least one size is specified
if [ "${#SIZES[@]}" -eq 0 ]; then
  echo "Error: No sizes specified. Please specify at least one size using --size option or remove --no-default-sizes option."
  exit 1
fi

# Check if input file and output basename are provided
if [ "$#" -lt 2 ]; then
  echo "Error: Missing required arguments."
  helpMsg
  exit 1
fi

# Check if input file exists
if [ ! -f "$1" ]; then
  echo "Error: Input file '$1' does not exist."
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_BASENAME="$2"


# Get current directory of the script, following any/all symlinks if necessary
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}" )" )" >/dev/null 2>&1 && pwd )"

# Check if alpha.png exists in the script directory
if [ ! -f "$DIR/alpha.png" ]; then
  echo "Error: alpha.png not found in the script directory."
  exit 1
fi

# Process each size
for size in "${SIZES[@]}"; do
  processGif "$INPUT_FILE" "$OUTPUT_BASENAME" "$size" "$NO_SUFFIX"
done