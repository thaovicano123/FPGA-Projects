# PowerShell script to run DES simulations using WSL

# Check if WSL is available
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Windows Subsystem for Linux (WSL) is not installed." -ForegroundColor Red
    Write-Host "Please install WSL to run the simulations: https://docs.microsoft.com/en-us/windows/wsl/install"
    exit
}

# Run the bash script in WSL
Write-Host "Running DES control unit simulations in WSL..." -ForegroundColor Green
wsl bash -c "cd '$((Get-Location).Path.Replace('\','/'))/sim' && bash run_sim.sh"

Write-Host "`nTo view waveforms, use: wsl gtkwave sim/des_control_unit_improved.vcd" -ForegroundColor Cyan