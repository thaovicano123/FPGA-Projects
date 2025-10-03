@echo off
REM Script để biên dịch và chạy mô phỏng DES Control Unit

echo Compiling DES Control Unit and testbench...
iverilog -o des_control_unit_sim.vvp des_control_unit.v des_control_unit_tb.v

if %errorlevel% neq 0 (
    echo Compilation failed!
    exit /b %errorlevel%
)

echo Running simulation...
vvp des_control_unit_sim.vvp

echo Generating waveform file...
REM Nếu bạn muốn xem waveform bằng GTKWave
REM gtkwave des_control_unit_tb.vcd

echo Done.