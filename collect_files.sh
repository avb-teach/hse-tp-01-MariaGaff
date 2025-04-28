#!/bin/bash

copy_files() {
    local input_dir="$1"
    local output_dir="$2"
    local max_depth="$3"

    find "$input_dir" -type f -print0 | while IFS= read -r -d $'\0' file; do
        local rel_path="${file#"$input_dir/"}"
        local depth=$(echo "$rel_path" | tr -d -c / | wc -c)

        local dest_dir="$output_dir"
        local dest_file=""

        if [[ -n "$max_depth" ]] && (( depth > max_depth )); then
            local dir_prefix=""
            local filename=$(basename "$file")
            local parent_dir=$(dirname "$rel_path")

            local IFS='/' read -r -a path_parts <<< "$parent_dir"
            local i=0
            for part in "${path_parts[@]}"; do
              ((i++))
              if [[ $i -gt $max_depth ]]; then
                dir_prefix+="${part}_"
              fi
            done

            dest_file="${dir_prefix}${filename}"
            local truncated_path=""
            local i=0
            for part in "${path_parts[@]}"; do
              ((i++))
              if [[ $i -le $max_depth ]]; then
                truncated_path+="${part}/"
              fi
            done
            truncated_path="${truncated_path%?}"
            dest_dir="$output_dir/$truncated_path"

        else
            dest_file="$rel_path"
        fi

        mkdir -p "$dest_dir"
        cp "$file" "$dest_dir/$dest_file"
    done
}

input_dir="$1"
output_dir="$2"
max_depth=""

if [[ "$#" -gt 2 ]]; then
    if [[ "$3" == "--max_depth" ]] && [[ "$4" =~ ^[0-9]+$ ]]; then
        max_depth="$4"
    else
        echo "Usage: $0 <input_dir> <output_dir> [--max_depth <depth>]"
        exit 1
    fi
fi

copy_files "$input_dir" "$output_dir" "$max_depth"

echo "Копирование в  $output_dir завершено."