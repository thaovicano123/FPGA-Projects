@echo off
REM Batch file to run DES simulations using MSYS2/MinGW or similar environment
REM This assumes Icarus Verilog and GTKWave are installed and in the PATH

echo Running DES control unit simulations...

REM Check if iverilog is available
where iverilog >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Icarus Verilog not found in PATH
    echo Please install Icarus Verilog: https://bleyer.org/icarus/
    exit /b 1
)

REM Set paths
set RTL_DIR=rtl
set SIM_DIR=sim

REM Compile basic control unit
echo Compiling basic control unit...
iverilog -o %SIM_DIR%\des_control_unit_tb.vvp %RTL_DIR%\des_control_unit.v %SIM_DIR%\des_control_unit_tb.v

REM Run simulation for basic control unit
echo Running basic control unit simulation...
vvp %SIM_DIR%\des_control_unit_tb.vvp

REM Compile improved control unit
echo Compiling improved control unit...
iverilog -o %SIM_DIR%\des_control_unit_improved_tb.vvp %RTL_DIR%\des_control_unit_improved.v %SIM_DIR%\des_control_unit_improved_tb.v

REM Run simulation for improved control unit
echo Running improved control unit simulation...
vvp %SIM_DIR%\des_control_unit_improved_tb.vvp

echo Simulations complete!

REM Check if GTKWave is available to view waveforms
where gtkwave >nul 2>&1
if %ERRORLEVEL% eq 0 (
    echo To view waveforms, use: gtkwave %SIM_DIR%\des_control_unit_improved.vcd
) else (
    echo GTKWave not found. Please install GTKWave to view waveforms.
)

pause