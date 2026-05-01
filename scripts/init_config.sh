#!/bin/bash

AI_ITERATION_CONFIG="
BeadForge AI Iteration Configuration
=====================================
Project: BeadForge
Created: $(date)
Max Retries: 3
Max Changes Per Iteration: 500
Lock Timeout: 3600
"

echo "$AI_ITERATION_CONFIG" > /workspace/.ai_context/config.txt

cat > /workspace/.ai_context/iteration_history.json << 'EOF'
{
  "iterations": [],
  "last_backup_sha": "",
  "current_version": "1.0.0",
  "stats": {
    "total_iterations": 0,
    "successful_improvements": 0,
    "failed_attempts": 0,
    "total_rollback": 0
  }
}
EOF

echo "Configuration initialized"
