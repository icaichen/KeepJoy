#!/bin/bash
# 运行国际版本的脚本

echo "🌍 运行 KeepJoy 国际版本..."
echo ""

# 如果提供了设备参数，使用该设备
if [ -n "$1" ]; then
  echo "📱 目标设备: $1"
  flutter run --flavor global -t lib/main_global.dart -d "$1"
else
  echo "📱 选择设备..."
  flutter run --flavor global -t lib/main_global.dart
fi
