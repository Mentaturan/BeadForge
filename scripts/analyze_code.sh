#!/bin/bash

LOCK_FILE="/workspace/.ai_context/iteration.lock"
LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE")
    if kill -0 "$LOCK_PID" 2>/dev/null; then
        echo "[$(date)] Another iteration is running (PID: $LOCK_PID). Exiting."
        exit 1
    else
        echo "[$(date)] Stale lock found, removing..."
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
    exit 0
}
trap cleanup EXIT INT TERM

analyze_code() {
    local report_file="$LOG_DIR/analysis/analysis_$TIMESTAMP.txt"
    mkdir -p "$(dirname "$report_file")"
    
    echo "=== BeadForge Code Analysis Report ===" > "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "File Statistics:" >> "$report_file"
    wc -l /workspace/BeadForge.html >> "$report_file"
    wc -c /workspace/BeadForge.html >> "$report_file"
    echo "" >> "$report_file"
    
    echo "HTML Structure Analysis:" >> "$report_file"
    grep -c "<html" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "0" >> "$report_file"
    grep -c "<head>" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "0" >> "$report_file"
    grep -c "<body>" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "0" >> "$report_file"
    grep -c "<script" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "0" >> "$report_file"
    grep -c "<style" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "0" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "CSS Variables:" >> "$report_file"
    grep -o '\-\-[a-zA-Z0-9-]*:' /workspace/BeadForge.html | sort | uniq -c | sort -rn >> "$report_file"
    echo "" >> "$report_file"
    
    echo "JavaScript Functions:" >> "$report_file"
    grep -oP 'function\s+\w+' /workspace/BeadForge.html | sort | uniq >> "$report_file"
    echo "" >> "$report_file"
    
    echo "Potential Issues:" >> "$report_file"
    grep -n "console\.log" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "No console.log found" >> "$report_file"
    grep -n "debugger" /workspace/BeadForge.html >> "$report_file" 2>/dev/null || echo "No debugger found" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "Code Quality Metrics:" >> "$report_file"
    JS_LINES=$(grep -c "<script" /workspace/BeadForge.html)
    CSS_LINES=$(grep -c "<style" /workspace/BeadForge.html)
    echo "Script tags: $JS_LINES" >> "$report_file"
    echo "Style tags: $CSS_LINES" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "Analysis complete. Report saved to: $report_file"
    echo "$report_file"
}

CODE_SIZE=$(wc -c < /workspace/BeadForge.html)
if [ "$CODE_SIZE" -gt 500000 ]; then
    echo "ERROR: BeadForge.html is too large (>500KB)"
    exit 1
fi

analyze_code
