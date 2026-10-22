#!/usr/bin/env bash
# 一键授予电视护眼卫士所需的全部权限
# 用法: tools/setup-tv-permissions.sh [设备序列号]
set -euo pipefail

SERIAL="${1:-192.168.2.165:5555}"
PKG="com.tvcontrol.eyecare"

adb -s "$SERIAL" get-state >/dev/null 2>&1 || adb connect "$SERIAL" >/dev/null
adb -s "$SERIAL" get-state >/dev/null

# 运行时权限 + 签名级权限
for p in WRITE_SECURE_SETTINGS READ_EXTERNAL_STORAGE WRITE_EXTERNAL_STORAGE; do
  adb -s "$SERIAL" shell "pm grant $PKG android.permission.$p" 2>/dev/null || true
done

# AppOps 权限：使用情况访问、悬浮窗（这两项 pm grant 无效，只能走 appops）
for op in GET_USAGE_STATS SYSTEM_ALERT_WINDOW; do
  adb -s "$SERIAL" shell "appops set $PKG $op allow" 2>/dev/null || true
done

echo "=== 权限确认 ==="
adb -s "$SERIAL" shell "dumpsys package $PKG | grep -E 'WRITE_SECURE_SETTINGS:|READ_EXTERNAL_STORAGE:|WRITE_EXTERNAL_STORAGE:'"
adb -s "$SERIAL" shell "appops get $PKG | grep -E 'GET_USAGE_STATS|SYSTEM_ALERT_WINDOW'"
