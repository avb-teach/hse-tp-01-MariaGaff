#!/bin/bash

if [[ "$#" -lt 2 || "$#" -gt 3 ]] 
then
    echo "Ошибка: необходимы две директории (входная и выходная)"
    exit 1
fi

max_depth=0
input_dir=""
output_dir=""

for arg in "$@"; do
    if [[ "$arg" == "--max_depth" ]]
    then
        max_depth="$2"
        shift

    elif [[ -z "$input_dir" ]]
    then
        input_dir="$arg"

    elif [[ -z "$output_dir" ]]
    then
        output_dir="$arg"
    fi
done

if [ ! -d "$input_dir" ]
then
    echo "Ошибка: не существует входной директории"
    exit 1
fi

if [ ! -d "$output_dir" ]
then 
    mkdir -p "$output_dir"
fi

current_depth=0

copy_files() {
    local dir="$1"
    local depth="$2"

    for file in "$dir"/*
    do
        if [ -f "$file" ]
        then
            base=$(basename "$file")
            new_file="$output_dir/$base"
            counter=1

            while [[ -e "$new_file" ]]
            do
                new_file="${output_dir}/${base%.*}($counter).${base##*.}"
                ((counter++))
            done

            cp "$file" "$new_file"
        fi
    done

    if [[ $depth -lt $max_depth ]] || [[ $max_depth -eq 0 ]]
    then
        for subdir in "$dir"/*/
        do
            if [ -d "$subdir" ]
            then
                copy_files "$subdir" $((depth + 1))
            fi
        done
    fi
}

copy_files "$input_dir" $current_depth
