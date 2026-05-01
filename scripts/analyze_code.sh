#!/bin/bash
# BeadForge 代码分析脚本

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ANALYSIS_DIR="/workspace/automation_log/analysis"
REPORT_FILE="$ANALYSIS_DIR/analysis_${TIMESTAMP}.md"
HTML_FILE="/workspace/BeadForge.html"

echo "=== BeadForge 代码分析 ===" 
echo "时间: $(date)"
echo ""

# 统计基本信息
TOTAL_LINES=$(wc -l < "$HTML_FILE")
TOTAL_SIZE=$(du -h "$HTML_FILE" | cut -f1)
CSS_LINES=$(grep -c "<style>" "$HTML_FILE" || echo 0)
JS_LINES=$(grep -c "<script>" "$HTML_FILE" || echo 0)

# 分析HTML结构
HTML_TAGS=$(grep -oE "<[a-zA-Z][^>]*>" "$HTML_FILE" | wc -l)
DIV_COUNT=$(grep -c "<div" "$HTML_FILE" || echo 0)
BUTTON_COUNT=$(grep -c "<button" "$HTML_FILE" || echo 0)
INPUT_COUNT=$(grep -c "<input" "$HTML_FILE" || echo 0)
CANVAS_COUNT=$(grep -c "<canvas" "$HTML_FILE" || echo 0)

# 分析CSS
CSS_SIZE=$(sed -n '/<style>/,/<\/style>/p' "$HTML_FILE" | wc -l)
CSS_SELECTORS=$(sed -n '/<style>/,/<\/style>/p' "$HTML_FILE" | grep -c "{" || echo 0)

# 分析JavaScript
JS_SIZE=$(sed -n '/<script>/,/<\/script>/p' "$HTML_FILE" | wc -l)
FUNCTION_COUNT=$(grep -c "function\|=>" "$HTML_FILE" || echo 0)
EVENT_LISTENERS=$(grep -c "addEventListener" "$HTML_FILE" || echo 0)

# 性能问题检测
INLINE_STYLES=$(grep -c "style=" "$HTML_FILE" || echo 0)
LONG_FUNCTIONS=$(grep -c "function.*{.*{.*{" "$HTML_FILE" || echo 0)
DOM_QUERIES=$(grep -c "getElementById\|querySelector" "$HTML_FILE" || echo 0)

# 代码质量问题
TODO_COUNT=$(grep -ci "TODO\|FIXME\|HACK\|XXX" "$HTML_FILE" || echo 0)
CONSOLE_LOGS=$(grep -c "console\." "$HTML_FILE" || echo 0)
DUPLICATE_IDS=$(grep -oE 'id="[^"]*"' "$HTML_FILE" | sort | uniq -d | wc -l)

# 生成报告
cat > "$REPORT_FILE" << EOF
# BeadForge 代码分析报告

**分析时间**: $(date)

## 基本信息

| 指标 | 数值 |
|------|------|
| 总行数 | $TOTAL_LINES |
| 文件大小 | $TOTAL_SIZE |
| HTML标签数 | $HTML_TAGS |
| div元素数 | $DIV_COUNT |
| button元素数 | $BUTTON_COUNT |
| input元素数 | $INPUT_COUNT |
| canvas元素数 | $CANVAS_COUNT |

## CSS分析

| 指标 | 数值 |
|------|------|
| CSS代码行数 | $CSS_SIZE |
| CSS选择器数 | $CSS_SELECTORS |

## JavaScript分析

| 指标 | 数值 |
|------|------|
| JS代码行数 | $JS_SIZE |
| 函数数量 | $FUNCTION_COUNT |
| 事件监听器数 | $EVENT_LISTENERS |

## 性能问题

| 问题 | 数量 | 状态 |
|------|------|------|
| 内联样式 | $INLINE_STYLES | $([ $INLINE_STYLES -gt 50 ] && echo "⚠️ 过多" || echo "✅ 正常") |
| DOM查询次数 | $DOM_QUERIES | $([ $DOM_QUERIES -gt 100 ] && echo "⚠️ 过多" || echo "✅ 正常") |

## 代码质量问题

| 问题 | 数量 | 状态 |
|------|------|------|
| TODO/FIXME | $TODO_COUNT | $([ $TODO_COUNT -gt 0 ] && echo "⚠️ 需处理" || echo "✅ 无") |
| console.log | $CONSOLE_LOGS | $([ $CONSOLE_LOGS -gt 10 ] && echo "⚠️ 过多" || echo "✅ 正常") |
| 重复ID | $DUPLICATE_IDS | $([ $DUPLICATE_IDS -gt 0 ] && echo "❌ 错误" || echo "✅ 无") |

## 改进建议

1. **性能优化**
   - 考虑将CSS和JS分离到独立文件
   - 使用事件委托减少事件监听器数量
   - 缓存DOM查询结果

2. **代码质量**
   - 移除生产环境中的console.log
   - 处理所有TODO/FIXME注释
   - 确保所有ID唯一

3. **可维护性**
   - 将大函数拆分为小函数
   - 添加更多代码注释
   - 考虑使用模块化设计

---
*报告生成于 $(date)*
EOF

echo "分析报告已保存到: $REPORT_FILE"
echo ""
cat "$REPORT_FILE"
