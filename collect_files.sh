#!/bin/bash

max_depth=3

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--max_depth)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]
            then
                max_depth="$2"
                shift 2
            else
                echo "Ошибка: после $1 ожидается неотрицательное число" >&2
                exit 1
            fi
            ;;
        -*)
            echo "Неизвестная опция: $1" >&2
            echo "Использование: $0 [--max_depth N] INPUT_DIR [OUTPUT_DIR]" >&2
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"

if [[ $# -lt 1 || $# -gt 2 ]]
then
    echo "Ошибка: нужно указать INPUT_DIR и необязательно OUTPUT_DIR" >&2
    echo "Использование: $0 [--max_depth N] INPUT_DIR [OUTPUT_DIR]" >&2
    exit 1
fi

input_dir="${1%/}"
if [[ $# -eq 2 ]] 
then
    output_dir="${2%/}"
else
    output_dir="."
fi

if [[ ! -d "$input_dir" ]] 
then
    echo "Ошибка: входная директория '$input_dir' не существует" >&2
    exit 1
fi

mkdir -p "$output_dir"

max_dirs=$(( max_depth - 1 ))
(( max_dirs < 0 )) && max_dirs=0

find "$input_dir" -type f | while IFS= read -r file
do
    rel="${file#$input_dir/}"
    dirpath=$(dirname "$rel")
    base=$(basename "$rel")

    if [[ "$dirpath" == "." ]]
    then
        segments=()
    else
        IFS='/' read -r -a segments <<< "$dirpath"
    fi
    N=${#segments[@]}

    if (( N <= max_dirs ))
    then
        new_rel_dir="$dirpath"
    else
        start=$(( N - max_dirs ))
        if (( max_dirs > 0 )) 
        then
            tail=( "${segments[@]:start:max_dirs}" )
            new_rel_dir="${tail[*]// /\/}"
        else
            new_rel_dir=""
        fi
    fi

    if [[ -n "$new_rel_dir" && "$new_rel_dir" != "." ]] 
    then
        dest="$output_dir/$new_rel_dir"
    else
        dest="$output_dir"
    fi
    mkdir -p "$dest"

    name="${base%.*}"
    ext="${base##*.}"
    dest_file="$dest/$base"
    counter=1
    while [[ -e "$dest_file" ]] 
    do
        dest_file="$dest/${name}($counter).$ext"
        ((counter++))
    done

    cp "$file" "$dest_file"
done

exit 0
