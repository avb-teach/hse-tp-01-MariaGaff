 #!/bin/bash

set -e
set -o pipefail

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

mkdir -p "$output_directory"
if [[ ! -d "$output_directory" ]]; then
    echo "Ошибка: Не удалось создать выходную директорию '$output_directory'." >&2
    exit 1
fi
if [[ ! -w "$output_directory" ]]; then
    echo "Ошибка: Выходная директория '$output_directory' не доступна для записи." >&2
    exit 1
fi

echo "Поиск файлов в '$input_directory'..."

find "$input_directory" -type f -print0 | while IFS= read -r -d $'\0' current_file; do
    base_name=$(basename "$current_file")

    target_path="$output_directory/$base_name"

    if [[ -e "$target_path" ]]; then
        echo "Обнаружен конфликт имен для '$base_name'. Поиск уникального имени..."
        counter=1
        name_part="${base_name%.*}"
        if [[ "$base_name" == *.* && "$base_name" != "$name_part" ]]; then
             ext_part=".${base_name##*.}"
        else
             name_part="$base_name"
             ext_part=""
        fi

        while true; do
            new_target_path="${output_directory}/${name_part}(${counter})${ext_part}"
            if [[ ! -e "$new_target_path" ]]; then
                target_path="$new_target_path"
                echo "  -> Новое имя: '$(basename "$target_path")'"
                break 
            fi
            ((counter++))
            if [[ "$counter" -gt 9999 ]]; then
                 echo "Ошибка: Не удалось найти уникальное имя для '$base_name' после $counter попыток." >&2
                 continue 2 
            fi
        done
    fi
    
    echo "Копирование '$current_file' -> '$target_path'"
    cp "$current_file" "$target_path"

done

echo "----------------------------------------"
echo "Все файлы успешно скопированы в '$output_directory'."
exit 0