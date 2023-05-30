#!/bin/bash

combine_images() {
  local folder="$1"
  local output_suffix="_arm"

  # Check if at least two files are found
  local ao_file=$(find "$folder" -type f -iname "*_ao.*" -print -quit)
  local rough_file=$(find "$folder" -type f -iname "*_rough.*" -print -quit)
  local metal_file=$(find "$folder" -type f -iname "*_metal.*" -print -quit)

  if [[ -z "$ao_file" && -z "$rough_file" ]] ||
     [[ -z "$ao_file" && -z "$metal_file" ]] ||
     [[ -z "$rough_file" && -z "$metal_file" ]]; then
    echo "At least two image files with suffixes _ao, _rough, or _metal not found in $folder."
    return 1
  fi

  local base_name="${ao_file%_*}"
  local file_extension="${ao_file##*.}"
  local output_file="${base_name}${output_suffix}.${file_extension}"

  convert \
    \( "$ao_file" -channel R -separate +channel \) \
    \( "$rough_file" -channel G -separate +channel \) \
    \( "$metal_file" -channel B -separate +channel \) \
    -combine \
    "$output_file"

  echo "Combined image created: $output_file"
}

traverse_folder() {
  local folder="$1"

  # Check if a folder is provided as an argument
  if [ $# -eq 0 ]; then
    echo "Please provide a folder as an argument."
    return 1
  fi

  find "$folder" -mindepth 1 -type d -not -path '*/.*' | while read -r dir; do
    if ! find "$dir" -mindepth 1 -type d | read; then
      combine_images "$dir"
    fi
  done
}

# Check if a folder path is provided as a command line argument
if [ $# -eq 0 ]; then
  echo "Please provide a folder path as a command line argument."
  exit 1
fi

# Use the command line argument as the folder path
folder_path="$1"
