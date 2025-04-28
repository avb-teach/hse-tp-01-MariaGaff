#!/bin/bash

copy_files_recursive() {
  local current_dir="$1"
  local output_dir="$2"
  local current_depth="$3"
  local max_depth="$4"
  local max_depth_enabled="$5"

  if $max_depth_enabled && [ "$current_depth" -gt "$max_depth" ]; then
    return
  fi

  mkdir -p "$output_dir"

  for file in "$current_dir"/*; do
    if [ -f "$file" ]; then
      local relative_path="${file#"$input_directory"/}"
      local destination_file="$output_dir/$relative_path"

      mkdir -p "$(dirname "$destination_file")"

      local index=1
      local base_name="${destination_file%.*}"
      local extension="${destination_file##*.}"
      while [[ -e "$destination_file" ]]; do
          destination_file="${base_name}($index).${extension}"
          ((index++))
      done

      cp "$file" "$destination_file"
    fi
  done

  for subdir in "$current_dir"/*; do
    if [ -d "$subdir" ]; then
      local next_depth=$((current_depth + 1))
      local next_output_dir="$output_dir/$(basename "$subdir")" 
      copy_files_recursive "$subdir" "$next_output_dir" "$next_depth" "$max_depth" "$max_depth_enabled"
    fi
  done
}


if [[ "$#" -lt 2 ]]; then
  echo "Ошибка: требуется указать входную и выходную директории."
  exit 1
fi

input_directory="$1"
output_directory="$2"
max_depth=0
max_depth_enabled=false

if [[ "$#" -ge 4 && "$3" == "--max_depth" ]]; then
  if [[ "$4" =~ ^[0-9]+$ ]]; then
    max_depth="$4"
    max_depth_enabled=true
  else
    echo "Ошибка: глубина должна быть числом."
    exit 1
  fi
fi

if [ ! -d "$input_directory" ]; then
  echo "Ошибка: входная директория не найдена."
  exit 1
fi

if [ ! -d "$output_directory" ]; then
  mkdir -p "$output_directory"
fi

copy_files_recursive "$input_directory" "$output_directory" 1 "$max_depth" "$max_depth_enabled"

echo "Все файлы скопированы в $output_directory."