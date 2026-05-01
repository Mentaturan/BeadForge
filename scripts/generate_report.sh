#!/bin/bash

LOG_DIR="/workspace/automation_log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$LOG_DIR/report_$TIMESTAMP.html"

mkdir -p "$(dirname "$REPORT_FILE")"

cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BeadForge AI 迭代报告</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2d3748;
            margin-bottom: 8px;
            font-size: 28px;
        }
        .subtitle {
            color: #718096;
            font-size: 14px;
            margin-bottom: 24px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .stat-box {
            background: #f7fafc;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #4a5568;
        }
        .stat-label {
            color: #718096;
            font-size: 14px;
            margin-top: 4px;
        }
        .section-title {
            color: #2d3748;
            font-size: 18px;
            margin: 24px 0 16px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e2e8f0;
        }
        .log-list {
            list-style: none;
        }
        .log-list li {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .log-list li:last-child { border-bottom: none; }
        .log-time { color: #718096; font-size: 12px; }
        .log-status { 
            padding: 4px 12px; 
            border-radius: 12px; 
            font-size: 12px;
            font-weight: 500;
        }
        .status-success { background: #c6f6d5; color: #22543d; }
        .status-pending { background: #feebc8; color: #744210; }
        .status-error { background: #fed7d7; color: #742a2a; }
        .footer {
            text-align: center;
            color: rgba(255,255,255,0.8);
            font-size: 12px;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>🎨 BeadForge AI 迭代报告</h1>
            <p class="subtitle">Generated: TIMESTAMP_PLACEHOLDER</p>
            
            <div class="stats">
                <div class="stat-box">
                    <div class="stat-value">ITERATION_COUNT</div>
                    <div class="stat-label">总迭代次数</div>
                </div>
                <div class="stat-box">
                    <div class="stat-value">SUCCESS_COUNT</div>
                    <div class="stat-label">成功改进</div>
                </div>
                <div class="stat-box">
                    <div class="stat-value">ROLLBACK_COUNT</div>
                    <div class="stat-label">回滚次数</div>
                </div>
                <div class="stat-box">
                    <div class="stat-value">UPTIME</div>
                    <div class="stat-label">系统运行时间</div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2 class="section-title">📋 迭代历史</h2>
            <ul class="log-list">
                <li>
                    <div>
                        <strong>迭代 #LATEST_ITERATION</strong>
                        <div class="log-time">LATEST_TIME</div>
                    </div>
                    <span class="log-status status-STATUS">STATUS_TEXT</span>
                </li>
            </ul>
        </div>
        
        <div class="card">
            <h2 class="section-title">📁 最近日志</h2>
            <ul class="log-list">
EOF

find "$LOG_DIR" -type f -name "*.log" -mtime -1 | head -5 | while read logfile; do
    echo "                <li>" >> "$REPORT_FILE"
    echo "                    <div><strong>$(basename "$logfile")</strong></div>" >> "$REPORT_FILE"
    echo "                    <span class=\"log-time\">$(stat -c %y "$logfile" | cut -d' ' -f1,2 | cut -d'.' -f1)</span>" >> "$REPORT_FILE"
    echo "                </li>" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << 'EOF'
            </ul>
        </div>
        
        <div class="card">
            <h2 class="section-title">🔧 自动化系统状态</h2>
            <ul class="log-list">
                <li>
                    <div><strong>代码分析</strong></div>
                    <span class="log-status status-success">就绪</span>
                </li>
                <li>
                    <div><strong>测试套件</strong></div>
                    <span class="log-status status-success">就绪</span>
                </li>
                <li>
                    <div><strong>备份系统</strong></div>
                    <span class="log-status status-success">就绪</span>
                </li>
                <li>
                    <div><strong>定时任务</strong></div>
                    <span class="log-status status-success">每小时执行</span>
                </li>
            </ul>
        </div>
        
        <div class="footer">
            <p>BeadForge AI Automation System</p>
            <p>确保代码质量 · 持续迭代改进</p>
        </div>
    </div>
</body>
</html>
EOF

sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/" "$REPORT_FILE"
sed -i "s/ITERATION_COUNT/0/" "$REPORT_FILE"
sed -i "s/SUCCESS_COUNT/0/" "$REPORT_FILE"
sed -i "s/ROLLBACK_COUNT/0/" "$REPORT_FILE"
sed -i "s/UPTIME/运行中/" "$REPORT_FILE"
sed -i "s/LATEST_ITERATION/0/" "$REPORT_FILE"
sed -i "s/LATEST_TIME/系统初始化/" "$REPORT_FILE"
sed -i "s/STATUS_TEXT/等待首次迭代/" "$REPORT_FILE"
sed -i "s/STATUS/pending/" "$REPORT_FILE"

echo ""
echo "报告生成完成"
echo "HTML报告: $REPORT_FILE"
