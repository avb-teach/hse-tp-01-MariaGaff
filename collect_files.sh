#!/bin/bash

if [[ "$#" -lt 2 ]]
then
    echo "Ошибка: требуется указать входную и выходную директории."
    exit 1
fi

input_directory="$1"
output_directory="$2"
max_depth=0

if [[ "$#" -ge 4 && "$3" == "--max_depth" ]]
then
    max_depth="$4"
fi

if [ ! -d "$input_directory" ]
then
    echo "Ошибка: входная директория не найдена."
    exit 1
fi

if [ ! -d "$output_directory" ]
then
    mkdir -p "$output_directory"
fi

find_args=("find" "$input_directory" -mindepth 1 -type f)
if [ "$max_depth" -gt 0 ]
then
    find_args+=("-maxdepth" "$max_depth")
fi

while IFS= read -r current_file
do
    relative_path="${current_file#"$input_directory"/}"
    destination_file="$output_directory/$relative_path"
    
    mkdir -p "$(dirname "$destination_file")"

    index=1
    base_name="${destination_file%.*}"
    extension="${destination_file##*.}"

    while [[ -e "$destination_file" ]]
    do
        destination_file="${base_name}($index).${extension}"
        ((index++))
    done

    cp "$current_file" "$destination_file"
done < <("${find_args[@]}" )

echo "Все файлы успешно скопированы в $output_directory."