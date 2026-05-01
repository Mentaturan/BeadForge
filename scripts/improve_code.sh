#!/bin/bash

LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
IMPROVEMENT_FILE="$LOG_DIR/improvements/improvement_$TIMESTAMP.txt"
HTML_FILE="/workspace/BeadForge.html"

mkdir -p "$(dirname "$IMPROVEMENT_FILE")"

echo "=== 代码改进记录 ===" > "$IMPROVEMENT_FILE"
echo "时间: $(date)" >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"

echo "开始分析代码改进点..." >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"

HAS_IMPROVEMENT=0
ORIGINAL_SIZE=$(wc -c < "$HTML_FILE")

check_and_improve() {
    local search_pattern="$1"
    local description="$2"
    local improvement_script="$3"
    
    if grep -q "$search_pattern" "$HTML_FILE"; then
        echo "发现可改进点: $description" >> "$IMPROVEMENT_FILE"
        echo "- 当前状态: 已存在" >> "$IMPROVEMENT_FILE"
        echo "- 评估: 保持现状" >> "$IMPROVEMENT_FILE"
        echo "" >> "$IMPROVEMENT_FILE"
    fi
}

check_and_improve "console\.log" "调试代码" ""
check_and_improve "debugger" "断点调试" ""

if ! grep -q "use strict" "$HTML_FILE"; then
    echo "发现可改进点: 添加严格模式" >> "$IMPROVEMENT_FILE"
    echo "- 当前状态: 缺少'use strict'" >> "$IMPROVEMENT_FILE"
    echo "- 建议: 在脚本开头添加'use strict'以启用严格模式" >> "$IMPROVEMENT_FILE"
    echo "" >> "$IMPROVEMENT_FILE"
fi

if ! grep -q "localStorage" "$HTML_FILE"; then
    echo "发现可改进点: 添加本地存储" >> "$IMPROVEMENT_FILE"
    echo "- 当前状态: 未使用 localStorage" >> "$IMPROVEMENT_FILE"
    echo "- 建议: 添加自动保存功能" >> "$IMPROVEMENT_FILE"
    echo "" >> "$IMPROVEMENT_FILE"
fi

if ! grep -q "addEventListener" "$HTML_FILE"; then
    echo "发现可改进点: 改进事件绑定" >> "$IMPROVEMENT_FILE"
    echo "- 当前状态: 使用内联事件绑定" >> "$IMPROVEMENT_FILE"
    echo "- 建议: 使用 addEventListener 替代" >> "$IMPROVEMENT_FILE"
    echo "" >> "$IMPROVEMENT_FILE"
fi

PERFORMANCE_ISSUES=0
if grep -q "for.*for" "$HTML_FILE"; then
    echo "发现可改进点: 嵌套循环性能" >> "$IMPROVEMENT_FILE"
    echo "- 当前状态: 检测到嵌套循环" >> "$IMPROVEMENT_FILE"
    echo "- 建议: 优化算法复杂度" >> "$IMPROVEMENT_FILE"
    echo "" >> "$IMPROVEMENT_FILE"
    PERFORMANCE_ISSUES=$((PERFORMANCE_ISSUES + 1))
fi

if grep -q "innerHTML" "$HTML_FILE"; then
    INNER_HTML_COUNT=$(grep -o "innerHTML" "$HTML_FILE" | wc -l)
    if [ "$INNER_HTML_COUNT" -gt 5 ]; then
        echo "发现可改进点: innerHTML 使用过多" >> "$IMPROVEMENT_FILE"
        echo "- 当前状态: 使用 innerHTML $INNER_HTML_COUNT 次" >> "$IMPROVEMENT_FILE"
        echo "- 建议: 考虑使用 textContent 或 createElement" >> "$IMPROVEMENT_FILE"
        echo "" >> "$IMPROVEMENT_FILE"
        PERFORMANCE_ISSUES=$((PERFORMANCE_ISSUES + 1))
    fi
fi

echo "=== 改进总结 ===" >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"
echo "性能相关问题: $PERFORMANCE_ISSUES" >> "$IMPROVEMENT_FILE"
echo "代码质量建议: 已记录" >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"

echo "--- 实施小幅度改进 ---" >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"

if ! grep -q "htmlhint" "$HTML_FILE"; then
    if ! grep -q 'lang="zh-CN"' "$HTML_FILE"; then
        sed -i 's/<html>/<html lang="zh-CN">/' "$HTML_FILE"
        echo "1. 已添加 lang 属性到 html 标签" >> "$IMPROVEMENT_FILE"
        HAS_IMPROVEMENT=1
    fi
fi

if ! grep -q "viewport-fit=cover" "$HTML_FILE"; then
    if grep -q 'viewport content=' "$HTML_FILE"; then
        sed -i 's/viewport content=/viewport content="width=device-width, initial-scale=1.0, viewport-fit=cover"/' "$HTML_FILE"
        echo "2. 已改进 viewport meta 标签" >> "$IMPROVEMENT_FILE"
        HAS_IMPROVEMENT=1
    fi
fi

if grep -q "var " "$HTML_FILE"; then
    VAR_COUNT=$(grep -o "\bvar\b" "$HTML_FILE" | wc -l)
    if [ "$VAR_COUNT" -gt 0 ]; then
        echo "3. 检测到 $VAR_COUNT 处使用 var，建议后续改为 let/const" >> "$IMPROVEMENT_FILE"
    fi
fi

NEW_SIZE=$(wc -c < "$HTML_FILE")
SIZE_DIFF=$((NEW_SIZE - ORIGINAL_SIZE))

echo "" >> "$IMPROVEMENT_FILE"
echo "=== 变更统计 ===" >> "$IMPROVEMENT_FILE"
echo "原始大小: $ORIGINAL_SIZE bytes" >> "$IMPROVEMENT_FILE"
echo "新大小: $NEW_SIZE bytes" >> "$IMPROVEMENT_FILE"
echo "变化: $SIZE_DIFF bytes" >> "$IMPROVEMENT_FILE"
echo "" >> "$IMPROVEMENT_FILE"
echo "改进文件: $IMPROVEMENT_FILE" >> "$IMPROVEMENT_FILE"

echo ""
echo "代码改进分析完成"
echo "报告保存到: $IMPROVEMENT_FILE"

if [ $HAS_IMPROVEMENT -eq 1 ]; then
    echo "已实施小幅度改进"
    exit 0
else
    echo "仅完成分析，无破坏性变更"
    exit 0
fi
