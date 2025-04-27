#!/bin/bash

if [[ "$#" -lt 2 || "$#" -gt 3 ]]
then
    echo "Ошибка: необходимы две директории (входная и выходная)"
    exit 1
fi

max_depth=0
input_dir=""
output_dir=""

while [[ "$#" -gt 0 ]]
do
    case "$1" in
        --max_depth)
            shift
            if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]
            then
                max_depth="$1"
                shift
            else
                echo "Ошибка: необходимо указать целое число после --max_depth"
                exit 1
            fi
            ;;
        *)
            if [[ -z "$input_dir" ]]
            then
                input_dir="$1"
            elif [[ -z "$output_dir" ]]
            then
                output_dir="$1"
            else
                echo "Ошибка: слишком много аргументов"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ ! -d "$input_dir" ]
then
    echo "Ошибка: не существует входной директории"
    exit 1
fi

if [ ! -d "$output_dir" ]
then 
    mkdir -p "$output_dir" || { echo "Ошибка: не удалось создать выходную директорию"; exit 1; }
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

            cp "$file" "$new_file" || { echo "Ошибка при копировании файла $file"; }
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
