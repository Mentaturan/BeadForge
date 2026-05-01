#!/bin/bash

TEST_RESULTS_DIR="/workspace/automation_log/test_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$TEST_RESULTS_DIR/test_results_$TIMESTAMP.txt"

mkdir -p "$TEST_RESULTS_DIR"

echo "=== BeadForge Test Suite ===" > "$RESULTS_FILE"
echo "Run Date: $(date)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

TEST_PASSED=0

test_html_syntax() {
    echo "--- Test 1: HTML Syntax Basic Check ---" >> "$RESULTS_FILE"
    
    if grep -q "<!DOCTYPE html>" /workspace/BeadForge.html; then
        echo "✓ DOCTYPE declaration found" >> "$RESULTS_FILE"
    else
        echo "✗ DOCTYPE declaration missing" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    if grep -q "<html" /workspace/BeadForge.html && grep -q "</html>" /workspace/BeadForge.html; then
        echo "✓ HTML tags properly closed" >> "$RESULTS_FILE"
    else
        echo "✗ HTML tags not properly closed" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    if grep -q "<head>" /workspace/BeadForge.html && grep -q "</head>" /workspace/BeadForge.html; then
        echo "✓ HEAD tags properly closed" >> "$RESULTS_FILE"
    else
        echo "✗ HEAD tags not properly closed" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    if grep -q "<body>" /workspace/BeadForge.html && grep -q "</body>" /workspace/BeadForge.html; then
        echo "✓ BODY tags properly closed" >> "$RESULTS_FILE"
    else
        echo "✗ BODY tags not properly closed" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    echo "" >> "$RESULTS_FILE"
}

test_json_files() {
    echo "--- Test 2: JSON Test Files Validation ---" >> "$RESULTS_FILE"
    
    for json_file in /workspace/test_*.json; do
        if [ -f "$json_file" ]; then
            if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
                echo "✓ $(basename $json_file) is valid JSON" >> "$RESULTS_FILE"
            else
                echo "✗ $(basename $json_file) has invalid JSON syntax" >> "$RESULTS_FILE"
                TEST_PASSED=1
            fi
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
}

test_javascript_syntax() {
    echo "--- Test 3: JavaScript Syntax Extraction Check ---" >> "$RESULTS_FILE"
    
    JS_CONTENT=$(sed -n '/<script>/,/<\/script>/p' /workspace/BeadForge.html | sed '1d;$d')
    
    if echo "$JS_CONTENT" | grep -q "function"; then
        echo "✓ JavaScript functions detected" >> "$RESULTS_FILE"
    else
        echo "⚠ No JavaScript functions found" >> "$RESULTS_FILE"
    fi
    
    OPEN_BRACE=$(echo "$JS_CONTENT" | tr -cd '{' | wc -c)
    CLOSE_BRACE=$(echo "$JS_CONTENT" | tr -cd '}' | wc -c)
    OPEN_PAREN=$(echo "$JS_CONTENT" | tr -cd '(' | wc -c)
    CLOSE_PAREN=$(echo "$JS_CONTENT" | tr -cd ')' | wc -c)
    OPEN_BRACKET=$(echo "$JS_CONTENT" | tr -cd '[' | wc -c)
    CLOSE_BRACKET=$(echo "$JS_CONTENT" | tr -cd ']' | wc -c)
    
    UNCLOSED=$((OPEN_BRACE + OPEN_PAREN + OPEN_BRACKET))
    CLOSED=$((CLOSE_BRACE + CLOSE_PAREN + CLOSE_BRACKET))
    
    if [ "$UNCLOSED" -eq "$CLOSED" ]; then
        echo "✓ Bracket count balanced: $UNCLOSED" >> "$RESULTS_FILE"
    else
        echo "✗ Bracket mismatch: opened=$UNCLOSED, closed=$CLOSED" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    echo "" >> "$RESULTS_FILE"
}

test_css_structure() {
    echo "--- Test 4: CSS Structure Check ---" >> "$RESULTS_FILE"
    
    CSS_CONTENT=$(sed -n '/<style>/,/<\/style>/p' /workspace/BeadForge.html | sed '1d;$d')
    
    if echo "$CSS_CONTENT" | grep -q "\."; then
        echo "✓ CSS class selectors detected" >> "$RESULTS_FILE"
    else
        echo "⚠ No CSS class selectors found" >> "$RESULTS_FILE"
    fi
    
    if echo "$CSS_CONTENT" | grep -q "#"; then
        echo "✓ CSS ID selectors detected" >> "$RESULTS_FILE"
    else
        echo "⚠ No CSS ID selectors found" >> "$RESULTS_FILE"
    fi
    
    OPEN_BRACE=$(echo "$CSS_CONTENT" | tr -cd '{' | wc -c)
    CLOSE_BRACE=$(echo "$CSS_CONTENT" | tr -cd '}' | wc -c)
    
    if [ "$OPEN_BRACE" -eq "$CLOSE_BRACE" ]; then
        echo "✓ CSS braces balanced: $OPEN_BRACE" >> "$RESULTS_FILE"
    else
        echo "✗ CSS braces mismatch: opened=$OPEN_BRACE, closed=$CLOSE_BRACE" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    echo "" >> "$RESULTS_FILE"
}

test_file_integrity() {
    echo "--- Test 5: File Integrity Check ---" >> "$RESULTS_FILE"
    
    FILE_SIZE=$(wc -c < /workspace/BeadForge.html)
    if [ "$FILE_SIZE" -gt 50000 ] && [ "$FILE_SIZE" -lt 500000 ]; then
        echo "✓ File size reasonable: $FILE_SIZE bytes" >> "$RESULTS_FILE"
    else
        echo "⚠ File size unusual: $FILE_SIZE bytes" >> "$RESULTS_FILE"
    fi
    
    if grep -q "<script>" /workspace/BeadForge.html && grep -q "</script>" /workspace/BeadForge.html; then
        echo "✓ Script tags properly formatted" >> "$RESULTS_FILE"
    else
        echo "✗ Script tags issue detected" >> "$RESULTS_FILE"
        TEST_PASSED=1
    fi
    
    echo "" >> "$RESULTS_FILE"
}

test_critical_functions() {
    echo "--- Test 6: Critical Functions Presence Check ---" >> "$RESULTS_FILE"
    
    CRITICAL_FUNCS="render draw save load export"
    
    for func in $CRITICAL_FUNCS; do
        if grep -q "function.*$func" /workspace/BeadForge.html; then
            echo "✓ Critical function '$func' found" >> "$RESULTS_FILE"
        else
            echo "⚠ Critical function '$func' not found" >> "$RESULTS_FILE"
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
}

test_html_syntax
test_json_files
test_javascript_syntax
test_css_structure
test_file_integrity
test_critical_functions

echo "=== Test Summary ===" >> "$RESULTS_FILE"
if [ $TEST_PASSED -eq 0 ]; then
    echo "ALL TESTS PASSED ✓" >> "$RESULTS_FILE"
else
    echo "SOME TESTS FAILED ✗" >> "$RESULTS_FILE"
fi
echo "" >> "$RESULTS_FILE"
echo "Results saved to: $RESULTS_FILE" >> "$RESULTS_FILE"

echo "Test execution complete. Exit code: $TEST_PASSED"
exit $TEST_PASSED
