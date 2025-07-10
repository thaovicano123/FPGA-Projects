@echo off
title FPGA Clock Update - Tang Nano 4K
color 0A

echo ╔═══════════════════════════════════════════════════╗
echo ║           🕐 FPGA CLOCK TIME UPDATE 🕐           ║
echo ║               Tang Nano 4K Project               ║
echo ╚═══════════════════════════════════════════════════╝
echo.

REM Check if we're in the right directory
if not exist "src\clock_counter.v" (
    echo ❌ Lỗi: Không tìm thấy file src\clock_counter.v
    echo    Vui lòng chạy script trong thư mục project!
    echo.
    pause
    exit /b 1
)

echo 🕐 Thời gian hiện tại trên máy: %TIME%
echo 📅 Ngày hiện tại: %DATE%
echo.

REM Extract current time
for /f "tokens=1-3 delims=:" %%a in ("%TIME%") do (
    set HOUR=%%a
    set MINUTE=%%b
    set SECOND=%%c
)

REM Remove leading spaces and get only first 2 digits of second
set HOUR=%HOUR: =%
set MINUTE=%MINUTE: =%
set SECOND=%SECOND:~0,2%

REM Add offset seconds (30 seconds for build time)
set /a "OFFSET_SEC=%SECOND%+30"
set /a "OFFSET_MIN=%MINUTE%"
set /a "OFFSET_HOUR=%HOUR%"

REM Handle second overflow
if %OFFSET_SEC% GEQ 60 (
    set /a "OFFSET_SEC=%OFFSET_SEC%-60"
    set /a "OFFSET_MIN=%OFFSET_MIN%+1"
)

REM Handle minute overflow  
if %OFFSET_MIN% GEQ 60 (
    set /a "OFFSET_MIN=%OFFSET_MIN%-60"
    set /a "OFFSET_HOUR=%OFFSET_HOUR%+1"
)

REM Handle hour overflow
if %OFFSET_HOUR% GEQ 24 (
    set /a "OFFSET_HOUR=%OFFSET_HOUR%-24"
)

echo ⚙️  Thời gian sẽ set cho FPGA: %OFFSET_HOUR%:%OFFSET_MIN%:%OFFSET_SEC%
echo    (Đã thêm 30 giây offset cho quá trình build)
echo.

echo 🔄 Đang cập nhật file clock_counter.v...

REM Create temporary PowerShell script to update the file
echo $content = Get-Content 'src\clock_counter.v' -Raw > temp_update.ps1
echo $content = $content -replace 'localparam INIT_HOUR = 5''d\d+;', 'localparam INIT_HOUR = 5''d%OFFSET_HOUR%;' >> temp_update.ps1
echo $content = $content -replace 'localparam INIT_MIN = 6''d\d+;', 'localparam INIT_MIN = 6''d%OFFSET_MIN%;' >> temp_update.ps1
echo $content = $content -replace 'localparam INIT_SEC = 6''d\d+;', 'localparam INIT_SEC = 6''d%OFFSET_SEC%;' >> temp_update.ps1
echo $content ^| Set-Content 'src\clock_counter.v' -Encoding UTF8 >> temp_update.ps1

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File temp_update.ps1 2>nul

REM Clean up
del temp_update.ps1 2>nul

echo ✅ Cập nhật thành công! Thời gian FPGA: %OFFSET_HOUR%:%OFFSET_MIN%:%OFFSET_SEC%
echo.

echo ╔═══════════════════════════════════════════════════╗
echo ║                🎯 BƯỚC TIẾP THEO                  ║
echo ╚═══════════════════════════════════════════════════╝
echo.
echo 1. 🔨 Mở Gowin EDA IDE
echo 2. 📂 Mở project: RTC_Clock_Display.gprj  
echo 3. ⚡ Build: Process → Place ^& Route (Ctrl+R)
echo 4. 📱 Nạp: Tools → Programmer → Program
echo 5. 🔄 Reset board bằng nút reset
echo 6. 🎊 Kiểm tra màn hình HDMI!
echo.

echo ⏱️  Tổng thời gian: ~1 phút (build + nạp + reset)
echo ⚠️  Lưu ý: Nếu build quá 30 giây, đồng hồ có thể nhanh vài giây
echo.

echo 📋 Checklist:
echo    [ ] Update time ✅ (Hoàn thành)
echo    [ ] Build project
echo    [ ] Program FPGA  
echo    [ ] Reset board
echo    [ ] Verify display
echo.

echo 🚀 Chúc bạn thành công!
pause 