#!/bin/bash

max_depth=0 
input_dir=""
output_dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--max_depth)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                max_depth="$2"
                shift 2
            else
                echo "Ошибка: после $1 ожидается неотрицательное число" >&2
                exit 1
            fi
            ;;
        -*)
            echo "Неизвестная опция: $1" >&2
            echo "Использование: $0 [--max_depth N] INPUT_DIR OUTPUT_DIR" >&2
            exit 1
            ;;
        *)
            if [[ -z "$input_dir" ]]; then
                input_dir="${1%/}"
            elif [[ -z "$output_dir" ]]; then
                output_dir="${1%/}"
            else
                echo "Ошибка: слишком много аргументов" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$input_dir" || -z "$output_dir" ]]; then
    echo "Ошибка: нужно указать INPUT_DIR и OUTPUT_DIR" >&2
    echo "Использование: $0 [--max_depth N] INPUT_DIR OUTPUT_DIR" >&2
    exit 1
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: входная директория '$input_dir' не существует" >&2
    exit 1
fi

mkdir -p "$output_dir" || {
    echo "Ошибка: не удалось создать выходную директорию '$output_dir'" >&2
    exit 1
}

find_cmd=("find" "$input_dir" "-type" "f")
if [[ $max_depth -gt 0 ]]; then
    find_cmd+=("-maxdepth" "$max_depth")
fi

"${find_cmd[@]}" | while IFS= read -r -d $'\n' file; do
    filename=$(basename -- "$file")
    extension="${filename##*.}"
    name="${filename%.*}"
    
    if [[ "$filename" == "$extension" ]]; then
        name="$filename"
        extension=""
    fi
    
    target_file="$output_dir/$filename"
    counter=1

    while [[ -e "$target_file" ]]; do
        if [[ -n "$extension" ]]; then
            target_file="$output_dir/${name}_${counter}.${extension}"
        else
            target_file="$output_dir/${name}_${counter}"
        fi
        ((counter++))
    done

    cp -- "$file" "$target_file" || {
        echo "Ошибка: не удалось скопировать $file" >&2
    }
done

exit 0