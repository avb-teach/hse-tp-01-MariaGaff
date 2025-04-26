#!/bin/bash

if [[ "$#" -lt 2 || "$#" -gt 2 ]]; then
    echo "Ошибка: необходимо указать две директории (входную и выходную)"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Ошибка: не существует входной директории"
    exit 1
fi

if [ ! -d "$output_dir" ]; then 
    mkdir -p "$output_dir"
fi

find "$input_dir" -maxdepth 2 -type f -exec cp {} "$output_dir" \;