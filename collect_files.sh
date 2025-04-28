#!/bin/bash

if [[ "$#" -lt 2 ]]; then
    echo "Ошибка: требуется указать входную и выходную директории."
    exit 1
fi

input_directory="$1"
output_directory="$2"
max_depth=0

if [[ "$#" -eq 4 && "$3" == "--max_depth" ]]; then
    max_depth="$4"
fi

if [ ! -d "$input_directory" ]; then
    echo "Ошибка: входная директория не найдена."
    exit 1
fi

if [ ! -d "$output_directory" ]; then
    mkdir -p "$output_directory"
fi

find_command="find "$input_directory" -type f"
if [ "$max_depth" -gt 0 ]; then
    find_command+=" -maxdepth $max_depth"
fi

eval "$find_command" | while IFS= read -r current_file; do
    filename=$(basename "$current_file")
    destination_file="$output_directory/$filename"
    index=1

    while [[ -e "$destination_file" ]]; do
        destination_file="${output_directory}/${filename%.*}($index).${filename##*.}"
        ((index++))
    done

    cp "$current_file" "$destination_file"
done

echo "Все файлы успешно скопированы в $output_directory."
