@echo off
echo ================================================
echo       FPGA Clock Time Update (Simple)
echo ================================================
echo.

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

echo ⚙️  Phân tích thời gian:
echo    Giờ: %HOUR%
echo    Phút: %MINUTE%  
echo    Giây: %SECOND%
echo.

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

echo 🎯 Thời gian sẽ set cho FPGA (có offset +30s):
echo    %OFFSET_HOUR%:%OFFSET_MIN%:%OFFSET_SEC%
echo.

REM Ask user for confirmation
echo 📋 Bạn có muốn cập nhật thời gian này không?
echo    [Y] - Có, cập nhật ngay
echo    [N] - Không, thoát
echo    [M] - Nhập thời gian thủ công
echo.
set /p CHOICE="Nhập lựa chọn (Y/N/M): "

if /i "%CHOICE%"=="N" (
    echo ❌ Đã hủy cập nhật
    pause
    exit /b 0
)

if /i "%CHOICE%"=="M" (
    echo.
    echo 🕐 Nhập thời gian thủ công:
    set /p "OFFSET_HOUR=   Giờ (0-23): "
    set /p "OFFSET_MIN=   Phút (0-59): "
    set /p "OFFSET_SEC=   Giây (0-59): "
    echo.
    echo ✅ Sẽ sử dụng thời gian: %OFFSET_HOUR%:%OFFSET_MIN%:%OFFSET_SEC%
)

echo 🔄 Đang cập nhật file clock_counter.v...

REM Create temporary PowerShell script to update the file
echo $content = Get-Content 'src\clock_counter.v' -Raw > temp_update.ps1
echo $content = $content -replace 'localparam INIT_HOUR = 5''d\d+;', 'localparam INIT_HOUR = 5''d%OFFSET_HOUR%;' >> temp_update.ps1
echo $content = $content -replace 'localparam INIT_MIN = 6''d\d+;', 'localparam INIT_MIN = 6''d%OFFSET_MIN%;' >> temp_update.ps1
echo $content = $content -replace 'localparam INIT_SEC = 6''d\d+;', 'localparam INIT_SEC = 6''d%OFFSET_SEC%;' >> temp_update.ps1
echo $content ^| Set-Content 'src\clock_counter.v' -Encoding UTF8 >> temp_update.ps1

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File temp_update.ps1

REM Clean up
del temp_update.ps1

echo ✅ Đã cập nhật thành công!
echo    - Giờ: %OFFSET_HOUR%
echo    - Phút: %OFFSET_MIN%
echo    - Giây: %OFFSET_SEC%
echo.
echo 🎯 Hướng dẫn tiếp theo:
echo    1. Build project trong Gowin IDE
echo    2. Nạp bitstream vào Tang Nano 4K  
echo    3. Reset board để áp dụng thời gian mới
echo.
echo ⏰ Đồng hồ sẽ bắt đầu từ thời gian đã set!

pause 