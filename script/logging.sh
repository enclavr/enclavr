#!/bin/bash

# Logging functions for Enclavr Autonomous Agent

log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" | tee -a "$LOG_FILE"
}

log_debug() {
    log "[DEBUG] $1" "DEBUG"
}

log_info() {
    log "[INFO] $1" "INFO"
}

log_warn() {
    log "[WARN] $1" "WARN" >&2
}

log_error() {
    log "[ERROR] $1" "ERROR" >&2
}

init_logging() {
    if [ -f "$LOG_FILE" ]; then
        size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$size" -gt 10485760 ]; then
            mv "$LOG_FILE" "${LOG_FILE}.old"
            echo "Log rotated (was ${size} bytes)" > "$LOG_FILE"
        fi
    fi
}
