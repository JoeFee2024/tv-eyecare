@echo off
chcp 65001 >nul
setlocal

rem ===========================================================
rem  电视护眼卫士 - 一键授权脚本（Windows）
rem
rem  用法:
rem    tools\setup-tv-permissions.bat [设备序列号]
rem    例:  tools\setup-tv-permissions.bat 192.168.2.165:5555
rem
rem  不带参数时默认连接 192.168.2.165:5555
rem  脚本需在「电视护眼卫士」已安装的前提下运行
rem ===========================================================

set "SERIAL=%~1"
if "%SERIAL%"=="" set "SERIAL=192.168.2.165:5555"
set "PKG=com.tvcontrol.eyecare"

echo ============================================
echo  电视护眼卫士 - 一键授权 (Windows)
echo  设备: %SERIAL%
echo ============================================
echo.

where adb >nul 2>&1
if errorlevel 1 (
    echo [错误] 找不到 adb 命令。
    echo.
    echo 请先下载 Android SDK Platform-Tools:
    echo   https://developer.android.com/tools/releases/platform-tools
    echo 下载解压后，把 platform-tools 目录加入系统 PATH，
    echo 再重新运行本脚本。
    echo.
    pause
    exit /b 1
)

echo [1/4] 连接电视 ...
adb -s "%SERIAL%" get-state >nul 2>&1
if errorlevel 1 adb connect "%SERIAL%" >nul 2>&1
adb -s "%SERIAL%" get-state >nul 2>&1
if errorlevel 1 (
    echo [错误] 无法连接电视 %SERIAL%
    echo.
    echo 请依次确认：
    echo   1. 电视上已经安装「电视护眼卫士」
    echo   2. 电视 已打开 开发者选项 / USB 调试 / 网络调试
    echo   3. 电视 IP 是否正确（电视上 设置 -^> 网络 里查看）
    echo.
    echo 当前 adb 已发现的设备：
    adb devices
    echo.
    echo 连接电视的写法：setup-tv-permissions.bat 电视IP:5555
    echo 或先执行：adb connect 电视IP:5555
    echo.
    pause
    exit /b 1
)
echo       连接成功
echo.

echo [2/4] 授予运行时与签名级权限 ...
for %%p in (WRITE_SECURE_SETTINGS READ_EXTERNAL_STORAGE WRITE_EXTERNAL_STORAGE) do (
    adb -s "%SERIAL%" shell pm grant %PKG% android.permission.%%p >nul 2>&1
    if errorlevel 1 (
        echo       [跳过] %%p
    ) else (
        echo       [完成] %%p
    )
)
echo.

echo [3/4] 设置 AppOps 权限（使用情况访问、悬浮窗）...
for %%o in (GET_USAGE_STATS SYSTEM_ALERT_WINDOW) do (
    adb -s "%SERIAL%" shell appops set %PKG% %%o allow >nul 2>&1
    if errorlevel 1 (
        echo       [跳过] %%o
    ) else (
        echo       [完成] %%o
    )
)
echo.

echo [4/4] 权限确认 ...
adb -s "%SERIAL%" shell dumpsys package %PKG% | findstr /C:"WRITE_SECURE_SETTINGS" /C:"READ_EXTERNAL_STORAGE" /C:"WRITE_EXTERNAL_STORAGE"
echo.
adb -s "%SERIAL%" shell appops get %PKG% | findstr /C:"GET_USAGE_STATS" /C:"SYSTEM_ALERT_WINDOW"
echo.

echo ============================================
echo  授权完成。请在电视上重新打开 APP，
echo  授权引导页会自动跳过。
echo ============================================
echo.
pause