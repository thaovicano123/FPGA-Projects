@echo off
REM Script để tự động chạy mô phỏng DES thông qua PowerShell và WSL

echo === Tự động chạy mô phỏng DES ===

REM Kiểm tra quyền admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Cần chạy với quyền Administrator để cài đặt WSL nếu cần.
    echo Vui lòng mở Command Prompt với quyền Administrator và chạy lại script này.
    pause
    exit /b 1
)

REM Kiểm tra PowerShell được cài đặt
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell không được tìm thấy. Vui lòng cài đặt PowerShell.
    pause
    exit /b 1
)

echo Đang chạy PowerShell script để mô phỏng DES...
PowerShell -ExecutionPolicy Bypass -File "%~dp0AutoRun_Simulation.ps1"

echo Hoàn thành.
pause