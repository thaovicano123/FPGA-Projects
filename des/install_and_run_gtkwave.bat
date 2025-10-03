@echo off
echo === Script cài đặt GTKWave cho Windows ===

echo Kiểm tra xem GTKWave đã được cài đặt chưa...
where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    echo GTKWave đã được cài đặt. Đang chạy...
    cd /d D:\project\FPGA\des
    start "" gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw
    exit /b 0
)

echo GTKWave chưa được cài đặt. Đang tải về...

REM Tạo thư mục tạm
mkdir %TEMP%\gtkwave_install >nul 2>&1

REM Tải GTKWave (bạn cần có internet)
powershell -Command "& {Invoke-WebRequest -Uri 'https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.111-bin-win64/gtkwave-3.3.111-bin-win64.zip/download' -OutFile '%TEMP%\gtkwave_install\gtkwave.zip'}"

if %errorlevel% neq 0 (
    echo Lỗi khi tải xuống GTKWave.
    echo Vui lòng tải thủ công từ: https://sourceforge.net/projects/gtkwave/files/
    echo Sau đó cài đặt và chạy lại script này.
    pause
    exit /b 1
)

echo Đang giải nén...
powershell -Command "& {Expand-Archive -Path '%TEMP%\gtkwave_install\gtkwave.zip' -DestinationPath '%TEMP%\gtkwave_install'}"

echo Đang cài đặt...
xcopy /E /I /Y "%TEMP%\gtkwave_install\gtkwave" "C:\Program Files\gtkwave"

echo Thêm vào PATH...
setx PATH "%PATH%;C:\Program Files\gtkwave\bin"

echo Dọn dẹp...
rmdir /S /Q %TEMP%\gtkwave_install

echo Cài đặt hoàn tất!
echo Đang chạy GTKWave...
cd /d D:\project\FPGA\des
start "" "C:\Program Files\gtkwave\bin\gtkwave.exe" des_control_unit_improved_tb.vcd des_wave_improved.gtkw

pause