@echo off
echo === Chạy mô phỏng DES đầy đủ với encryption/decryption ===

REM Kiểm tra xem môi trường WSL đã sẵn sàng
wsl echo "Checking WSL..." > nul 2>&1
if %errorlevel% neq 0 (
    echo Lỗi: WSL không hoạt động.
    echo Vui lòng đảm bảo Windows Subsystem for Linux được cài đặt và hoạt động.
    pause
    exit /b 1
)

echo Đang chạy mô phỏng cho DES đầy đủ...
wsl bash -c "cd /mnt/d/project/FPGA/des && dos2unix des_datapath_and_control.v des_full_tb.v && iverilog -o des_full_sim.vvp des_control_unit_improved.v des_datapath_and_control.v des_full_tb.v && vvp des_full_sim.vvp"

if %errorlevel% neq 0 (
    echo Có lỗi khi chạy mô phỏng.
    echo Vui lòng kiểm tra các file Verilog của bạn.
    pause
    exit /b 1
)

echo.
echo Mô phỏng đã hoàn thành.
echo Đang mở GTKWave để xem kết quả...

where gtkwave >nul 2>&1
if %errorlevel% equ 0 (
    echo Đang mở GTKWave từ Windows...
    start "" gtkwave des_full_tb.vcd des_full_wave.gtkw
) else (
    echo Đang thử mở GTKWave từ WSL...
    wsl bash -c "cd /mnt/d/project/FPGA/des && gtkwave des_full_tb.vcd des_full_wave.gtkw || echo 'GTKWave không khả dụng trong WSL. Vui lòng cài đặt GTKWave cho Windows hoặc cấu hình X server.'"
    echo.
    echo Nếu GTKWave không mở, vui lòng chạy install_and_run_gtkwave.bat để cài đặt GTKWave cho Windows.
)

pause