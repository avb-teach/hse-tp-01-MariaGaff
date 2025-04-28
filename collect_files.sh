#!/bin/bash

if [[ "$#" -lt 2 || "$#" -gt 2 ]] 
then
    echo "Ошибка: необходимы две директории (входная и выходная)"
    exit 1
fi

input_dir="${1%/}"
output_dir="${2%/}"
max_depth="$3"

if [[ ! -d "$input_dir" ]] 
then
    echo "Ошибка: входная директория не найдена"
    exit 1
fi

if ! [[ "$max_depth" =~ ^[0-9]+$ ]]
then
    echo "Ошибка: max_depth должен быть целым неотрицательным"
    exit 1
fi

mkdir -p "$output_dir"

max_dirs=$((max_depth - 1))
if (( max_dirs < 0 ))
then
    max_dirs=0
fi

find "$input_dir" -type f | while IFS= read -r file
do
    base=$(basename "$file")
    rel="${file#$input_dir/}"
    dirpath=$(dirname "$rel")

    if [[ "$dirpath" == "." ]] 
    then
        N=0
        segments=()
    else
        IFS='/' read -r -a segments <<< "$dirpath"
        N=${#segments[@]}
    fi

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
        dest_dir="$output_dir/$new_rel_dir"
    else
        dest_dir="$output_dir"
    fi

    mkdir -p "$dest_dir"

    ext="${base##*.}"
    name="${base%.*}"
    new_file="$dest_dir/$base"
    counter=1
    
    while [[ -e "$new_file" ]]
    do
        new_file="$dest_dir/${name}($counter).$ext"
        ((counter++))
    done

    cp "$file" "$new_file"
done
