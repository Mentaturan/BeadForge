#!/bin/bash

LOCK_FILE="/workspace/.ai_context/iteration.lock"
LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_RETRIES=3

if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE")
    if kill -0 "$LOCK_PID" 2>/dev/null; then
        echo "[$(date)] 另一个迭代进程正在运行 (PID: $LOCK_PID)。退出。"
        exit 1
    else
        echo "[$(date)] 发现过期锁文件，正在删除..."
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
    exit 0
}
trap cleanup EXIT INT TERM

cd /workspace

main_log="$LOG_DIR/iteration_$TIMESTAMP.log"
exec > >(tee -a "$main_log") 2>&1

echo "========================================="
echo "BeadForge AI 自动化迭代"
echo "时间: $(date)"
echo "========================================="

echo ""
echo ">>> 阶段0: 分支清理与同步"
echo "-----------------------------------"
./scripts/branch_cleanup.sh
BRANCH_CLEANUP_RESULT=$?
echo "分支清理完成，退出码: $BRANCH_CLEANUP_RESULT"
echo ""

echo ""
echo ">>> 阶段1: 准备阶段 - 创建备份"
echo "-----------------------------------"

BACKUP_SHA=$(./scripts/backup_rollback.sh backup 2>/dev/null | tail -1)
if [ -z "$BACKUP_SHA" ]; then
    BACKUP_SHA=$(git rev-parse HEAD)
fi
echo "备份点 SHA: $BACKUP_SHA"
echo ""

echo ">>> 阶段2: 代码分析"
echo "-----------------------------------"
./scripts/analyze_code.sh
ANALYSIS_RESULT=$?
echo "分析完成，退出码: $ANALYSIS_RESULT"
echo ""

echo ">>> 阶段3: 研究同类项目"
echo "-----------------------------------"
./scripts/research_similar_projects.sh
RESEARCH_RESULT=$?
echo "研究完成，退出码: $RESEARCH_RESULT"
echo ""

echo ">>> 阶段4: 实施改进"
echo "-----------------------------------"

RETRY_COUNT=0
IMPROVEMENT_SUCCESS=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "尝试 #$(($RETRY_COUNT + 1)) / $MAX_RETRIES"
    
    ./scripts/improve_code.sh
    IMPROVE_RESULT=$?
    
    if [ $IMPROVE_RESULT -eq 0 ]; then
        echo "改进实施成功"
        IMPROVEMENT_SUCCESS=1
        break
    else
        echo "改进失败，正在回滚..."
        ./scripts/backup_rollback.sh rollback
        RETRY_COUNT=$(($RETRY_COUNT + 1))
        
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "等待 5 秒后重试..."
            sleep 5
        fi
    fi
done

if [ $IMPROVEMENT_SUCCESS -eq 0 ]; then
    echo "警告: 所有重试均失败，跳过本次迭代"
fi
echo ""

echo ">>> 阶段5: 测试验证"
echo "-----------------------------------"
./scripts/run_tests.sh
TEST_RESULT=$?
echo ""

echo ">>> 阶段6: 提交或回滚"
echo "-----------------------------------"

if [ $TEST_RESULT -eq 0 ] && [ $IMPROVEMENT_SUCCESS -eq 1 ]; then
    echo "测试通过，准备提交..."
    
    IMPROVEMENT_LOG="$LOG_DIR/improvements/improvement_$TIMESTAMP.txt"
    if [ -f "$IMPROVEMENT_LOG" ]; then
        IMPROVEMENT_SUMMARY=$(head -5 "$IMPROVEMENT_LOG" | tail -1)
    else
        IMPROVEMENT_SUMMARY="代码改进"
    fi
    
    git add -A
    git commit -m "AI iteration: $IMPROVEMENT_SUMMARY - $TIMESTAMP"
    
    echo "提交完成: $(git rev-parse --short HEAD)"
    
    echo "推送到远程 main 分支..."
    git push origin main -f 2>/dev/null || git push origin main
else
    echo "测试失败或未进行改进，执行回滚..."
    ./scripts/backup_rollback.sh rollback
    echo "已回滚到备份点: $BACKUP_SHA"
fi
echo ""

echo ">>> 阶段7: 生成报告"
echo "-----------------------------------"
./scripts/generate_report.sh
echo ""

echo "========================================="
echo "迭代完成"
echo "时间: $(date)"
echo "========================================="

echo ""
echo "所有日志文件已保存到: $LOG_DIR"
echo "主日志: $main_log"
