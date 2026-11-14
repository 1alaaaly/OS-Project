#!/bin/bash

source ./lib.sh
echo "Library loaded successfully"
# Scan a directory and count its files and folders.
scan_directory() {
    local dir="$1"
    require_dir "$dir" || return 1

    local files=$(find "$dir" -type f | wc -l)
    local folders=$(find "$dir" -type d | wc -l)

    for f in $(find "$dir"); do
        if [ "$f" != "$dir" ]; then
            if [ -f "$f" ]; then
                echo "[file] $(basename "$f")"
            elif [ -d "$f" ]; then
                echo "[dir ] $(basename "$f")"
            fi
        fi
    done

    echo "Files: $files   Folders: $((folders - 1))"

    log_action "Scanned directory: $dir"
}


# Check permissions of every regular file in a directory.
permission_audit() {
    local dir="$1"
    require_dir "$dir" || return 1
    local unreadable=0
    local executable=0

    for f in $(find "$dir" -type f)
    do
        local permissions=""

        if [ -r "$f" ]; then
            permissions="${permissions}r"
        else
            permissions="${permissions}-"
        fi

        if [ -w "$f" ]; then
            permissions="${permissions}w"
        else
            permissions="${permissions}-"
        fi

        if [ -x "$f" ]; then
            permissions="${permissions}x"
            executable=$((executable + 1))
        else
            permissions="${permissions}-"
        fi

        if [ ! -r "$f" ]; then
            unreadable=$((unreadable + 1))
        fi

        echo "$permissions  $(basename "$f")"
    done

    echo "Unreadable files: $unreadable   Executable files: $executable"

    log_action "Audited file permissions in: $dir"
}


# Count files per extensions.
extension_report() {
    local dir="$1"
    require_dir "$dir" || return 1

    declare -A extensions

    extensions[txt]=0
    extensions[log]=0
    extensions[sh]=0
    extensions[jpg]=0
    extensions[other]=0

    for f in $(find "$dir" -type f)
    do
        if [[ "$f" == *.txt ]]; then
            extensions[txt]=$((extensions[txt] + 1))

        elif [[ "$f" == *.log ]]; then
            extensions[log]=$((extensions[log] + 1))

        elif [[ "$f" == *.sh ]]; then
            extensions[sh]=$((extensions[sh] + 1))

        elif [[ "$f" == *.jpg ]]; then
            extensions[jpg]=$((extensions[jpg] + 1))

        else
            extensions[other]=$((extensions[other] + 1))
        fi
    done

    echo "jpg : ${extensions[jpg]}"
    echo "log : ${extensions[log]}"
    echo "other : ${extensions[other]}"
    echo "sh : ${extensions[sh]}"
    echo "txt : ${extensions[txt]}"

    log_action "extension report for: $dir"
}


# Search for text inside file names in a directory.
search_file() {
    local dir="$1"
    require_dir "$dir" || return 1

    read -p "Enter text to search for: " search_text

    if [ -z "$(find "$dir" -type f -name "*$search_text*")" ]; then
        echo "No matching files found."
    else
        find "$dir" -type f -name "*$search_text*"
    fi

    log_action "Searched for '$search_text' in: $dir"
}



# Create backups for all readable files in the directory.
backup_all() {
    local dir="$1"
    require_dir "$dir" || return 1

    # Folder name
    local folder="backups"
    mkdir -p "$folder"

    # Counters
    local saved=0
    local skipped=0

    # Get current date and time
    local current_date=$(date +%Y%m%d_%H%M%S)

    # Loop through files
    for filename in "$dir"/*; do
        if [ -f "$filename" ]; then
            if [ -r "$filename" ]; then
                local backup_name="$folder/$(basename "$filename")_${current_date}.bak"

                cp "$filename" "$backup_name"
                saved=$((saved + 1))
            else
                skipped=$((skipped + 1))
                log_error "Cannot read $filename"
            fi
        fi
    done

    echo "Saved files: $saved"
    echo "Skipped files: $skipped"

    log_action "Backup completed"
}


# List saved backup files.
list_backups() {
    local folder="backups"
    local found=0

    for file in "$folder"/*.bak; do
        if [ -f "$file" ]; then
            echo "$(basename "$file")"
            found=1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "(no backups yet)"
    fi

    log_action "Listed backups"
}


# Restore a backup file.
restore_backup() {
    local dir="$1"
    local folder="backups"

    read -p "Enter backup name: " filename

    if [ -f "$folder/$filename" ]; then
        local restore_name="$dir/restored_$filename"

        if [ -f "$restore_name" ]; then
            log_error "File already exists."
            return 1
        fi

        cp "$folder/$filename" "$restore_name"
        log_action "Backup restored"
        echo "Restore completed."
    else
        log_error "Backup does not exist."
        return 1
    fi
}



# Get directory and action from command line.
dir="${1:-.}"
action="$2"

# If an action is given, run it directly.
if [ "$action" = "scan" ]; then
    scan_directory "$dir"

elif [ "$action" = "perms" ]; then
    permission_audit "$dir"

elif [ "$action" = "ext" ]; then
    extension_report "$dir"

elif [ "$action" = "backup" ]; then
    backup_all "$dir"

elif [ -n "$action" ]; then
    echo "Invalid action"

else
    # Show menu until the user chooses Exit.
    while true
    do
        echo "1. Scan directory"
        echo "2. Permission audit"
        echo "3. Extension report"
        echo "4. Search file"
        echo "5. Backup files"
        echo "6. List backups"
        echo "7. Restore backup"
        echo "8. Exit"

        read -p "Choose an option: " choice

        case "$choice" in
            1) scan_directory "$dir" ;;
            2) permission_audit "$dir" ;;
            3) extension_report "$dir" ;;
            4) search_file "$dir" ;;
            5) backup_all "$dir" ;;
            6) list_backups ;;
            7) restore_backup "$dir" ;;
            8) echo "Goodbye!"; break ;;
            *) echo "Invalid choice" ;;
        esac
    done
fi
