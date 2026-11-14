#!/bin/bash

# Prints an information message.
log_info() {
    echo "[INFO] $1"
}

# Prints an error message.
log_error() {
    echo "[ERROR] $1" >&2
}

# Saves an action with its date and time in auditor.log.
log_action() {
    local action="$1"
    local log_file="auditor.log"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action" >> "$log_file"
}

# Checks if the given directory exists.
require_dir() {
    if [ -d "$1" ]; then
        log_info "Directory exists."
        return 0
    else
        log_error "Directory does not exist."
        return 1
    fi
}
