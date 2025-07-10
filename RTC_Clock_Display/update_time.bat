@echo off
echo ================================================
echo         FPGA Clock Time Update Script
echo ================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python không được tìm thấy!
    echo    Vui lòng cài đặt Python và thêm vào PATH
    echo    Download tại: https://python.org
    pause
    exit /b 1
)

REM Run the Python script
echo 🚀 Đang cập nhật thời gian hiện tại...
echo.
python update_time.py

echo.
echo ================================================
echo 💡 Lưu ý: Hãy build lại project trong Gowin IDE
echo    để áp dụng thời gian mới!
echo ================================================
pause 