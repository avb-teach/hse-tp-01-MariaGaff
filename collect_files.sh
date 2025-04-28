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

copy_files() {
    local dir="$1"
    local current_depth="$2"
    local effective_depth=$((current_depth + 1))  

    for file in "$dir"/* "$dir"/.[!.]* "$dir"/..?*  
    do
        if [ -f "$file" ]
        then
            base=$(basename "$file")
            new_file="$output_dir/$base"
            counter=1

            while [[ -e "$new_file" ]]
            do
                new_file="${output_dir}/${base%.*}_${counter}.${base##*.}"  
                ((counter++))
            done

            cp "$file" "$new_file" || { echo "Ошибка при копировании файла $file"; }
        fi
    done

    if [[ $max_depth -eq 0 || $effective_depth -lt $max_depth ]]
    then
        for subdir in "$dir"/*/ "$dir"/.[!.]*/ "$dir"/..?*/ 
        do
            if [ -d "$subdir" ] && [ ! -L "$subdir" ]  
            then
                copy_files "$subdir" $effective_depth
            fi
        done
    fi
}

copy_files "$input_dir" 0