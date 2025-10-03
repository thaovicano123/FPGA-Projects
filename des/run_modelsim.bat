@echo off
REM Script để chạy mô phỏng bằng ModelSim/Questa

echo Running ModelSim/Questa simulation...

REM Kiểm tra nếu ModelSim/Questa được cài đặt
where vsim >nul 2>&1
if %errorlevel% neq 0 (
    echo ModelSim/Questa không được tìm thấy trong PATH. Vui lòng cài đặt hoặc thêm vào PATH.
    exit /b 1
)

REM Chạy ModelSim với script TCL
vsim -do run_modelsim.tcl

echo Done.