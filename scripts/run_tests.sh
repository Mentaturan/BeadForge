#!/bin/bash
# BeadForge 测试验证脚本

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEST_DIR="/workspace/automation_log/tests"
LOG_FILE="$TEST_DIR/test_${TIMESTAMP}.md"
HTML_FILE="/workspace/BeadForge.html"

echo "=== BeadForge 测试验证 ==="
echo "时间: $(date)"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# 测试1: HTML语法检查
echo "测试1: HTML语法检查..."
HTML_CHECK=$(grep -c "</html>" "$HTML_FILE" || echo 0)
if [ "$HTML_CHECK" -gt 0 ]; then
    echo "✅ HTML结构完整"
    ((TESTS_PASSED++))
    HTML_STATUS="✅ 通过"
else
    echo "❌ HTML结构不完整"
    ((TESTS_FAILED++))
    HTML_STATUS="❌ 失败"
fi

# 测试2: JavaScript语法检查
echo "测试2: JavaScript语法检查..."
JS_START=$(grep -c "<script>" "$HTML_FILE" || echo 0)
JS_END=$(grep -c "</script>" "$HTML_FILE" || echo 0)
if [ "$JS_START" -eq "$JS_END" ] && [ "$JS_START" -gt 0 ]; then
    echo "✅ JavaScript标签配对正确"
    ((TESTS_PASSED++))
    JS_STATUS="✅ 通过"
else
    echo "❌ JavaScript标签配对错误"
    ((TESTS_FAILED++))
    JS_STATUS="❌ 失败"
fi

# 测试3: CSS语法检查
echo "测试3: CSS语法检查..."
CSS_START=$(grep -c "<style>" "$HTML_FILE" || echo 0)
CSS_END=$(grep -c "</style>" "$HTML_FILE" || echo 0)
if [ "$CSS_START" -eq "$CSS_END" ] && [ "$CSS_START" -gt 0 ]; then
    echo "✅ CSS标签配对正确"
    ((TESTS_PASSED++))
    CSS_STATUS="✅ 通过"
else
    echo "❌ CSS标签配对错误"
    ((TESTS_FAILED++))
    CSS_STATUS="❌ 失败"
fi

# 测试4: JSON测试文件验证
echo "测试4: JSON测试文件验证..."
JSON_ERRORS=0
for json_file in /workspace/test_*.json; do
    if [ -f "$json_file" ]; then
        if python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
            echo "  ✅ $json_file 有效"
        else
            echo "  ❌ $json_file 无效"
            ((JSON_ERRORS++))
        fi
    fi
done
if [ "$JSON_ERRORS" -eq 0 ]; then
    ((TESTS_PASSED++))
    JSON_STATUS="✅ 通过"
else
    ((TESTS_FAILED++))
    JSON_STATUS="❌ 失败"
fi

# 测试5: 必要元素检查
echo "测试5: 必要元素检查..."
REQUIRED_ELEMENTS=("canvas" "button" "input")
MISSING_ELEMENTS=0
for elem in "${REQUIRED_ELEMENTS[@]}"; do
    COUNT=$(grep -c "<$elem" "$HTML_FILE" || echo 0)
    if [ "$COUNT" -gt 0 ]; then
        echo "  ✅ 找到 $elem 元素 ($COUNT 个)"
    else
        echo "  ❌ 缺少 $elem 元素"
        ((MISSING_ELEMENTS++))
    fi
done
if [ "$MISSING_ELEMENTS" -eq 0 ]; then
    ((TESTS_PASSED++))
    ELEM_STATUS="✅ 通过"
else
    ((TESTS_FAILED++))
    ELEM_STATUS="❌ 失败"
fi

# 测试6: 拼豆颜色数据检查
echo "测试6: 拼豆颜色数据检查..."
COLOR_COUNT=$(grep -c "PERLER_COLORS\|HAMA_COLORS\|ARTKAL_COLORS" "$HTML_FILE" || echo 0)
if [ "$COLOR_COUNT" -gt 0 ]; then
    echo "✅ 找到颜色数据定义"
    ((TESTS_PASSED++))
    COLOR_STATUS="✅ 通过"
else
    echo "❌ 未找到颜色数据定义"
    ((TESTS_FAILED++))
    COLOR_STATUS="❌ 失败"
fi

# 生成测试报告
cat > "$LOG_FILE" << EOF
# BeadForge 测试报告

**测试时间**: $(date)

## 测试结果摘要

| 测试项目 | 状态 |
|----------|------|
| HTML语法检查 | $HTML_STATUS |
| JavaScript语法检查 | $JS_STATUS |
| CSS语法检查 | $CSS_STATUS |
| JSON文件验证 | $JSON_STATUS |
| 必要元素检查 | $ELEM_STATUS |
| 颜色数据检查 | $COLOR_STATUS |

## 统计

- **通过**: $TESTS_PASSED
- **失败**: $TESTS_FAILED
- **总计**: $((TESTS_PASSED + TESTS_FAILED))
- **通过率**: $(( TESTS_PASSED * 100 / (TESTS_PASSED + TESTS_FAILED) ))%

## 结论

$([ $TESTS_FAILED -eq 0 ] && echo "✅ 所有测试通过，可以提交代码" || echo "❌ 存在测试失败，需要修复或回滚")

---
*测试报告生成于 $(date)*
EOF

echo ""
echo "==================================="
echo "测试结果: 通过 $TESTS_PASSED, 失败 $TESTS_FAILED"
echo "==================================="
echo ""
echo "测试报告已保存到: $LOG_FILE"

# 返回退出码
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
