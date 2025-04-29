#!/bin/bash

if [[ "$#" -lt 2 ]] 
then
    echo "Ошибка: требуется указать входную и выходную директории."
    exit 1
fi

input_directory="$1"
output_directory="$2"
max_depth=0
max_depth_enabled=false

if [[ "$#" -ge 4 && "$3" == "--max_depth" ]]
then
    if [[ "$4" =~ ^[0-9]+$ ]]
    then
        max_depth="$4"
        max_depth_enabled=true
    else
        echo "Ошибка: глубина должна быть числом."
        exit 1
    fi
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

find_args=("find" "$input_directory" -mindepth 1 -type f -print0)

while IFS= read -r -d $'\0' current_file
do
    relative_path="${current_file#"$input_directory"/}"
    IFS='/' read -r -a path_segments <<< "$relative_path"
    depth="${#path_segments[@]}"

    if $max_depth_enabled && [ "$depth" -gt "$max_depth" ]
    then
        flattened_name=""
        for ((i=max_depth; i<depth; i++))
        do
            flattened_name+="${path_segments[i]}_"
        done
        flattened_name="${flattened_name%_}"

        truncated_path=""
        for ((i=0; i<max_depth; i++))
        do
            truncated_path+="${path_segments[i]}/"
        done
        truncated_path="${truncated_path%/}"  

        relative_path="$truncated_path/$flattened_name"
    fi

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

echo "Все файлы скопированы в $output_directory."