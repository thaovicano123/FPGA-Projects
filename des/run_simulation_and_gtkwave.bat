@echo off
echo === Chạy lại mô phỏng DES Control Unit và mở GTKWave ===

REM Kiểm tra xem môi trường WSL đã sẵn sàng
wsl echo "Checking WSL..." > nul 2>&1
if %errorlevel% neq 0 (
    echo Lỗi: WSL không hoạt động.
    echo Vui lòng đảm bảo Windows Subsystem for Linux được cài đặt và hoạt động.
    pause
    exit /b 1
)

echo 1. Chạy mô phỏng cho module gốc
echo 2. Chạy mô phỏng cho module cải tiến
echo 3. Chạy cả hai
echo 4. Chỉ mở GTKWave với file mô phỏng hiện có
echo.

set /p choice="Lựa chọn của bạn (1-4): "

if "%choice%"=="1" (
    echo Đang chạy mô phỏng cho module DES Control Unit gốc...
    wsl bash -c "cd /mnt/d/project/FPGA/des && iverilog -o des_control_unit_sim.vvp des_control_unit.v des_control_unit_tb.v && vvp des_control_unit_sim.vvp"
    goto view_original
) else if "%choice%"=="2" (
    echo Đang chạy mô phỏng cho module DES Control Unit cải tiến...
    wsl bash -c "cd /mnt/d/project/FPGA/des && iverilog -o des_control_unit_improved_sim.vvp des_control_unit_improved.v des_control_unit_improved_tb.v && vvp des_control_unit_improved_sim.vvp"
    goto view_improved
) else if "%choice%"=="3" (
    echo Đang chạy mô phỏng cho cả hai module...
    wsl bash -c "cd /mnt/d/project/FPGA/des && iverilog -o des_control_unit_sim.vvp des_control_unit.v des_control_unit_tb.v && vvp des_control_unit_sim.vvp && iverilog -o des_control_unit_improved_sim.vvp des_control_unit_improved.v des_control_unit_improved_tb.v && vvp des_control_unit_improved_sim.vvp"
    goto view_choice
) else if "%choice%"=="4" (
    goto view_choice
) else (
    echo Lựa chọn không hợp lệ.
    pause
    exit /b 1
)

:view_choice
echo.
echo Bạn muốn xem waveform nào?
echo 1. Module DES Control Unit gốc
echo 2. Module DES Control Unit cải tiến
echo 3. Cả hai (mở hai cửa sổ GTKWave)
echo.

set /p view="Lựa chọn của bạn (1-3): "

if "%view%"=="1" (
    goto view_original
) else if "%view%"=="2" (
    goto view_improved
) else if "%view%"=="3" (
    goto view_both
) else (
    echo Lựa chọn không hợp lệ.
    pause
    exit /b 1
)

:view_original
echo Đang mở GTKWave cho module gốc...
where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    start "" gtkwave des_control_unit_tb.vcd des_wave.gtkw
) else (
    wsl bash -c "cd /mnt/d/project/FPGA/des && gtkwave des_control_unit_tb.vcd des_wave.gtkw || echo 'GTKWave không khả dụng trong WSL. Vui lòng cài đặt GTKWave cho Windows hoặc cấu hình X server.'"
    echo Nếu GTKWave không mở, vui lòng chạy install_and_run_gtkwave.bat để cài đặt GTKWave cho Windows.
)
exit /b 0

:view_improved
echo Đang mở GTKWave cho module cải tiến...
where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    start "" gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw
) else (
    wsl bash -c "cd /mnt/d/project/FPGA/des && gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw || echo 'GTKWave không khả dụng trong WSL. Vui lòng cài đặt GTKWave cho Windows hoặc cấu hình X server.'"
    echo Nếu GTKWave không mở, vui lòng chạy install_and_run_gtkwave.bat để cài đặt GTKWave cho Windows.
)
exit /b 0

:view_both
echo Đang mở GTKWave cho cả hai module...
where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    start "" gtkwave des_control_unit_tb.vcd des_wave.gtkw
    timeout /t 2 >nul
    start "" gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw
) else (
    wsl bash -c "cd /mnt/d/project/FPGA/des && (gtkwave des_control_unit_tb.vcd des_wave.gtkw || echo 'GTKWave không khả dụng') & (gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw || echo 'GTKWave không khả dụng')"
    echo Nếu GTKWave không mở, vui lòng chạy install_and_run_gtkwave.bat để cài đặt GTKWave cho Windows.
)
exit /b 0