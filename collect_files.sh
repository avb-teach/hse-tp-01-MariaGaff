#!/bin/bash

set -euo pipefail

APP_NAME=$(basename "$0")

usage() {
    echo "Usage: ${APP_NAME} <input_directory> <output_directory>"
    echo "Copies all files from <input_directory> (and its subdirectories) into <output_directory>,"
    echo "flattening the directory structure."
    echo "Duplicate filenames will be renamed with a suffix like '(1)', '(2)', etc."
}

if [[ "$#" -ne 2 ]]; then
    echo "Ошибка: Неверное количество аргументов." >&2 
    usage
    exit 1
fi

input_directory="$1"
output_directory="$2"

if [[ ! -d "$input_directory" ]]; then
    echo "Ошибка: Входная директория '$input_directory' не найдена или не является директорией." >&2
    exit 1
fi

mkdir -p "$output_directory" || {
    echo "Ошибка: Не удалось создать выходную директорию '$output_directory'." >&2
    exit 1
}

if [[ ! -w "$output_directory" ]]; then
    echo "Ошибка: Выходная директория '$output_directory' не доступна для записи." >&2
    exit 1
fi

echo "Поиск файлов в '$input_directory'..."

declare -A file_counts

process_file() {
    local src="$1"
    local base_name=$(basename "$src")
    local target_path="$output_directory/$base_name"
    local name_part="${base_name%.*}"
    local ext_part=""
    
    if [[ "$base_name" =~ ^..*\..+$ ]]; then
        ext_part=".${base_name##*.}"
    else
        name_part="$base_name"
    fi

    if [[ -e "$target_path" ]]; then
        echo "Обнаружен конфликт имен для '$base_name'. Поиск уникального имени..."
        local counter=${file_counts["$base_name"]:-1}
        
        while true; do
            new_target_path="${output_directory}/${name_part}(${counter})${ext_part}"
            if [[ ! -e "$new_target_path" ]]; then
                target_path="$new_target_path"
                echo "  -> Новое имя: '$(basename "$target_path")'"
                file_counts["$base_name"]=$((counter + 1))
                break
            fi
            ((counter++))
        done
    else
        file_counts["$base_name"]=1
    fi
    
    echo "Копирование '$src' -> '$target_path'"
    cp -- "$src" "$target_path" || {
        echo "Ошибка: Не удалось скопировать '$src'" >&2
        return 1
    }
}

while IFS= read -r -d $'\0' file; do
    process_file "$file"
done < <(find "$input_directory" -type f -print0)

echo "----------------------------------------"
echo "Все файлы успешно скопированы в '$output_directory'."
exit 0