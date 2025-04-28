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

find_command="find "$input_directory" -mindepth 1 -type f"
if [ "$max_depth" -gt 0 ]; then
    find_command+=" -maxdepth $max_depth"
fi

eval "$find_command" | while IFS= read -r current_file; do
    relative_path="${current_file#$input_directory/}"
    destination_file="$output_directory/$relative_path"
    
    mkdir -p "$(dirname "$destination_file")"

    index=1
    while [[ -e "$destination_file" ]]; do
        destination_file="${output_directory}/${relative_path%.*}($index).${relative_path##*.}"
        ((index++))
    done

    cp "$current_file" "$destination_file"
done

echo "Копирование завершено. Все файлы успешно скопированы в $output_directory."
