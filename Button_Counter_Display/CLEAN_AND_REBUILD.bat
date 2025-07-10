@echo off
echo Cleaning and rebuilding project...

echo Cleaning implementation folders...
rd /s /q "impl\gwsynthesis"
rd /s /q "impl\pnr"
rd /s /q "impl\temp"
mkdir "impl\gwsynthesis"
mkdir "impl\pnr"
mkdir "impl\temp"

echo Removing temporary files...
del /f /q *.bak

echo Creating clean project environment...
echo Project cleaned successfully!
echo.
echo Please open Button_Counter_Display.gprj in Gowin IDE and rebuild the project.
echo.
