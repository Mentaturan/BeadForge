#!/bin/bash

LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/improvements/branch_cleanup_$TIMESTAMP.txt"

mkdir -p "$(dirname "$LOG_FILE")"

echo "=== BeadForge 分支清理工具 ===" > "$LOG_FILE"
echo "执行时间: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

cleanup_local_branches() {
    echo "--- 清理本地临时分支 ---" >> "$LOG_FILE"
    # 切换到 main 分支确保安全
    git checkout main 2>/dev/null || git checkout master 2>/dev/null
    
    # 获取所有分支
    local_branches=$(git branch --format='%(refname:short)')
    
    for branch in $local_branches; do
        if [[ "$branch" == main || "$branch" == master ]]; then
            echo "✓ 保留主分支: $branch" >> "$LOG_FILE"
        elif [[ "$branch" == trae/* ]]; then
            echo "🗑️  删除临时分支: $branch" >> "$LOG_FILE"
            git branch -D "$branch" 2>/dev/null || echo "⚠️ 删除失败: $branch" >> "$LOG_FILE"
        fi
    done
    echo "" >> "$LOG_FILE"
}

cleanup_remote_branches() {
    echo "--- 清理远程临时分支 ---" >> "$LOG_FILE"
    
    # 获取所有远程分支
    remote_branches=$(git branch -r --format='%(refname:short)' | grep origin/)
    
    for branch in $remote_branches; do
        branch_name=$(echo "$branch" | sed 's|origin/||')
        if [[ "$branch_name" == main || "$branch_name" == master ]]; then
            echo "✓ 保留远程主分支: $branch" >> "$LOG_FILE"
        elif [[ "$branch_name" == trae/* ]]; then
            echo "🗑️ 删除远程临时分支: $branch" >> "$LOG_FILE"
            git push origin --delete "$branch_name" 2>/dev/null || echo "⚠️ 删除失败: $branch" >> "$LOG_FILE"
        fi
    done
    echo "" >> "$LOG_FILE"
}

sync_main_branch() {
    echo "--- 同步并确保 main 分支 ---" >> "$LOG_FILE"
    
    # 获取最新远程代码
    git fetch origin >> "$LOG_FILE" 2>&1
    
    # 确保在 main 分支上
    git checkout main 2>/dev/null || git checkout master 2>/dev/null
    
    # 重置到远程 main 分支（安全地）
    git reset --soft origin/main 2>/dev/null || true
    
    # 推送本地 main 分支（安全地）
    git push origin main -f 2>/dev/null || git push origin main >> "$LOG_FILE" 2>&1
    
    echo "✓ Main 分支已同步" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

verify_main_branch() {
    echo "--- 验证 Main 分支状态 ---" >> "$LOG_FILE"
    
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        echo "✓ 当前在主分支上: $current_branch" >> "$LOG_FILE"
    else
        echo "⚠️ 当前不在主分支上，正在切换..." >> "$LOG_FILE"
        git checkout main 2>/dev/null || git checkout master >> "$LOG_FILE" 2>&1
    fi
    
    # 显示分支状态
    echo "--- 当前分支状态 ---" >> "$LOG_FILE"
    git branch -a >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# 执行
cd /workspace || exit 1

verify_main_branch
cleanup_local_branches
sync_main_branch
# 暂时不自动删除远程分支，因为可能正在使用中
# cleanup_remote_branches

echo "=== 分支清理完成 ===" >> "$LOG_FILE"
echo "日志文件: $LOG_FILE" >> "$LOG_FILE"
echo ""

cat "$LOG_FILE"

