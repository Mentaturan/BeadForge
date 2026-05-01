#!/bin/bash

BACKUP_SHA_FILE="/workspace/.ai_context/last_backup_sha.txt"
LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

prepare_backup() {
    echo "[$(date)] Starting backup preparation..."
    
    cd /workspace
    
    CURRENT_SHA=$(git rev-parse HEAD 2>/dev/null)
    if [ -z "$CURRENT_SHA" ]; then
        echo "[$(date)] ERROR: Not a git repository or no commits"
        exit 1
    fi
    
    echo "$CURRENT_SHA" > "$BACKUP_SHA_FILE"
    
    BACKUP_MSG="Backup before AI iteration - $TIMESTAMP"
    git add -A
    git commit -m "$BACKUP_MSG" 2>/dev/null || true
    
    echo "[$(date)] Backup created at: $CURRENT_SHA"
    echo "$BACKUP_SHA_FILE"
    echo "$CURRENT_SHA"
}

rollback() {
    echo "[$(date)] Starting rollback..."
    
    if [ ! -f "$BACKUP_SHA_FILE" ]; then
        echo "[$(date)] ERROR: No backup SHA file found"
        exit 1
    fi
    
    BACKUP_SHA=$(cat "$BACKUP_SHA_FILE")
    
    cd /workspace
    
    if ! git rev-parse "$BACKUP_SHA" >/dev/null 2>&1; then
        echo "[$(date)] ERROR: Backup SHA $BACKUP_SHA not found"
        exit 1
    fi
    
    git reset --hard "$BACKUP_SHA"
    git clean -fd
    
    mkdir -p "$LOG_DIR/improvements"
    echo "Rollback to $BACKUP_SHA at $(date)" >> "$LOG_DIR/improvements/rollback_log.txt"
    
    echo "[$(date)] Rollback complete. Now at: $(git rev-parse HEAD)"
}

get_backup_sha() {
    if [ -f "$BACKUP_SHA_FILE" ]; then
        cat "$BACKUP_SHA_FILE"
    else
        echo ""
    fi
}

case "$1" in
    backup)
        prepare_backup
        ;;
    rollback)
        rollback
        ;;
    get-sha)
        get_backup_sha
        ;;
    *)
        echo "Usage: $0 {backup|rollback|get-sha}"
        exit 1
        ;;
esac
