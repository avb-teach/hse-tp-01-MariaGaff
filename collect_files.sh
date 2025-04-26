#!/bin/bash

if [[ "$#" -lt 2 || "$#" -gt 2 ]] 
then
    echo "Ошибка: необходимы две директории (входная и выходная)"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]
then
    echo "Ошибка: не существует входной директории"
    exit 1
fi

if [ ! -d "$output_dir" ]
then 
    mkdir -p "$output_dir"
fi

find "$input_dir" -type f | while read -r file 
do
    base=$(basename "$file")
    new_file="$output_dir/$base"
    counter=1

    while [[ -e "$new_file" ]] 
    do
        new_file="${output_dir}/${base%.*}($counter).${base##*.}"
        ((counter++))
    done

    cp "$file" "$new_file"
done