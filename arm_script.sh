#!/bin/bash

combine_images() {
  local folder="$1"
  local output_suffix="_arm"
  local path_from_root="$(pwd)"

  # finding the ambient occlusion, roughness and metal textures, case insensitive, and variations of the suffix
  # suffix can be _ao, -ao, Ambient for Ambient Occlusion Maps
  # suffix can be _rough, -rough, Rough for Rougness Maps
  # suffix can be _metal, -metal, Metal for Metal Maps
  local ao_file=$(find "$folder" -type f \( -iname "*_ao*" -o -iname "*-ao*" \) -print -quit)
  if [[ -n "$ao_file" ]]; then
	ao_file="${path_from_root}/${ao_file}"
  fi

  local rough_file=$(find "$folder" -type f \( -iname "*_rough*" -o -iname "*-rough*" \) -print -quit)
  if [[ -n "$rough_file" ]]; then
	rough_file="${path_from_root}/${rough_file}"
  fi

  # if the folder name already has the word metal in it, the metal texture will have two occurances of the word metal in it.
  if [[ "${1}" == *metal* ]]; then
    local metal_file=$(find "$folder" -type f -iname "*metal*metal*" -print -quit)
  else
    local metal_file=$(find "$folder" -type f \( -iname "*_metal*" -o -iname "*-metal*" \) -print -quit)
  fi
  if [[ -n "$metal_file" ]]; then
    metal_file="${path_from_root}/${metal_file}"
  fi

  # constructing the outputfilepath 
  # if at least one of the textures were found, the arm texture can be created.
  local base_name=""
  local file_extension=""
  
  if [ -n "$ao_file" ]; then
	base_name="${ao_file%%_ao*}"
	base_name="${base_name%%-ao*}"
	file_extension="${ao_file##*.}"
  elif [ -n "$rough_file" ]; then
	base_name="${rough_file%%_rough*}"
	base_name="${base_name%%-rough*}"
	file_extension="${rough_file##*.}"
  elif [ -n "$metal_file" ]; then
	base_name="${metal_file%%_metal*}"
	base_name="${base_name%%-metal*}"
	file_extension="${metal_file##*.}"
  else
	echo "no ao, rough or metal texture found in ${path_from_root}/${1}"
	return 1
  fi
  
  local output_file="${base_name}${output_suffix}.${file_extension}"

  # creating arguments for convert
  local args=(${ao_file} ${rough_file} ${metal_file} -combine ${output_file} ) 

  # creating the arm_file with convert and the args
  convert "${args[@]}" 2>/dev/null

  if [ ! $? -eq 0 ]; then
	echo "no combined image created for: ${output_file}"
	return 1
  fi

  return 0
}

traverse_folder() {
  local folder="$1"

  # looping through all folders and applying combine images in the leaf folders
  # ignoring hidden folders
  find "$folder" -type d -not -path '*/.*' | while read -r dir; do
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

traverse_folder "$1"
