#!/bin/bash

# Flutter应用实时日志监控脚本
# 用于捕获登录和用户信息获取过程中的详细日志

DEVICE_ID="662eb639"
LOG_FILE="flutter_app_logs.txt"

echo "=== Flutter应用日志监控 ==="
echo "设备ID: $DEVICE_ID"
echo "日志文件: $LOG_FILE"
echo "开始时间: $(date)"
echo "========================"
echo

# 启动Flutter应用并重定向日志
flutter run --debug -d $DEVICE_ID --verbose 2>&1 | tee $LOG_FILE &

# 获取后台进程ID
FLUTTER_PID=$!

echo "Flutter应用已启动 (PID: $FLUTTER_PID)"
echo "实时日志正在写入到: $LOG_FILE"
echo
echo "监控中的关键信息:"
echo "- 登录请求: login"
echo "- Token获取: token"
echo "- 用户信息: user"
echo "- 错误信息: ERROR, error, 失败"
echo "- 认证相关: Authorization, 401, 403"
echo
echo "按 Ctrl+C 停止监控"
echo

# 实时监控特定关键词
tail -f $LOG_FILE | grep --line-buffered -E "ERROR|error|失败|login|token|user|Authorization|401|403|获取用户信息" &

# 等待用户中断
trap "echo; echo '正在停止监控...'; kill $FLUTTER_PID 2>/dev/null; exit 0" INT

# 等待Flutter进程结束
wait $FLUTTER_PID