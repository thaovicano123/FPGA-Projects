# PowerShell script để tự động chạy mô phỏng DES thông qua WSL

Write-Host "=== Tự động chạy mô phỏng DES trên WSL (Ubuntu) ===" -ForegroundColor Green

# Kiểm tra WSL đã được cài đặt chưa
$wsl_installed = $false
try {
    $wsl_status = wsl --status
    $wsl_installed = $true
    Write-Host "WSL đã được cài đặt." -ForegroundColor Green
} catch {
    Write-Host "WSL chưa được cài đặt trên hệ thống này." -ForegroundColor Yellow
    $install_wsl = Read-Host "Bạn có muốn cài đặt WSL không? (Y/N)"
    if ($install_wsl -eq "Y" -or $install_wsl -eq "y") {
        Write-Host "Đang cài đặt WSL..." -ForegroundColor Cyan
        try {
            wsl --install
            Write-Host "WSL đã được cài đặt thành công." -ForegroundColor Green
            Write-Host "Bạn cần khởi động lại máy tính và chạy lại script này." -ForegroundColor Yellow
            Read-Host "Nhấn Enter để thoát"
            exit
        } catch {
            Write-Host "Lỗi khi cài đặt WSL. Vui lòng cài đặt thủ công." -ForegroundColor Red
            Read-Host "Nhấn Enter để thoát"
            exit
        }
    } else {
        Write-Host "WSL là bắt buộc để chạy môi trường Ubuntu. Thoát script." -ForegroundColor Red
        Read-Host "Nhấn Enter để thoát"
        exit
    }
}

# Kiểm tra Ubuntu đã được cài đặt trong WSL chưa
$ubuntu_installed = $false
try {
    $distro_list = wsl --list
    if ($distro_list -match "Ubuntu") {
        $ubuntu_installed = $true
        Write-Host "Ubuntu đã được cài đặt trong WSL." -ForegroundColor Green
    }
} catch {
    Write-Host "Lỗi khi kiểm tra các bản phân phối WSL." -ForegroundColor Red
}

if (-not $ubuntu_installed) {
    Write-Host "Ubuntu chưa được cài đặt trong WSL." -ForegroundColor Yellow
    $install_ubuntu = Read-Host "Bạn có muốn cài đặt Ubuntu không? (Y/N)"
    if ($install_ubuntu -eq "Y" -or $install_ubuntu -eq "y") {
        Write-Host "Đang cài đặt Ubuntu..." -ForegroundColor Cyan
        try {
            wsl --install -d Ubuntu
            Write-Host "Ubuntu đã được cài đặt thành công." -ForegroundColor Green
        } catch {
            Write-Host "Lỗi khi cài đặt Ubuntu. Vui lòng cài đặt thủ công." -ForegroundColor Red
            Read-Host "Nhấn Enter để thoát"
            exit
        }
    } else {
        Write-Host "Ubuntu là bắt buộc để chạy mô phỏng. Thoát script." -ForegroundColor Red
        Read-Host "Nhấn Enter để thoát"
        exit
    }
}

# Lấy đường dẫn hiện tại của script
$current_dir = $PSScriptRoot
if (-not $current_dir) {
    $current_dir = Get-Location
}

# Chuyển đổi đường dẫn Windows thành đường dẫn WSL
$wsl_path = wsl wslpath "'$current_dir'"

# Tạo script tạm thời cho WSL
$wsl_script = @"
#!/bin/bash
echo "=== Kiểm tra và cài đặt các công cụ cần thiết ==="

# Cập nhật package list
sudo apt-get update

# Kiểm tra Icarus Verilog đã được cài đặt chưa
if ! command -v iverilog &> /dev/null; then
    echo "Icarus Verilog chưa được cài đặt. Đang cài đặt..."
    sudo apt-get install -y iverilog
else
    echo "Icarus Verilog đã được cài đặt."
fi

# Kiểm tra GTKWave đã được cài đặt chưa
if ! command -v gtkwave &> /dev/null; then
    echo "GTKWave chưa được cài đặt. Đang cài đặt..."
    sudo apt-get install -y gtkwave
else
    echo "GTKWave đã được cài đặt."
fi

# Cài đặt make
if ! command -v make &> /dev/null; then
    echo "Make chưa được cài đặt. Đang cài đặt..."
    sudo apt-get install -y make
else
    echo "Make đã được cài đặt."
fi

# Cài đặt dos2unix
if ! command -v dos2unix &> /dev/null; then
    echo "dos2unix chưa được cài đặt. Đang cài đặt..."
    sudo apt-get install -y dos2unix
else
    echo "dos2unix đã được cài đặt."
fi

# Di chuyển đến thư mục dự án
cd $wsl_path

# Chuyển đổi line endings nếu cần
echo "Đang chuyển đổi line endings nếu cần..."
dos2unix *.v *.sh Makefile

# Cấp quyền thực thi cho script shell
chmod +x run_sim_ubuntu.sh

# Chạy mô phỏng bằng Makefile
echo "=== Đang chạy mô phỏng ==="
make sim

echo "=== Mô phỏng hoàn thành ==="
echo "Kết quả mô phỏng đã được hiển thị ở trên."
echo ""
echo "Để xem waveform, bạn cần chạy với GUI. Nếu đang sử dụng WSL, hãy cài đặt và cấu hình X-server (như VcXsrv) trên Windows."
echo "Sau đó, bạn có thể chạy 'make wave' để xem waveform."
echo ""
echo "Nhấn Enter để kết thúc..."
read
"@

# Lưu script tạm thời
$wsl_script | Out-File -FilePath "$current_dir\run_wsl_temp.sh" -Encoding utf8

# Chạy script trong WSL
Write-Host "Đang chuyển sang Ubuntu WSL để chạy mô phỏng..." -ForegroundColor Cyan
wsl bash "$wsl_path/run_wsl_temp.sh"

# Xóa script tạm thời sau khi hoàn thành
Remove-Item -Path "$current_dir\run_wsl_temp.sh"

Write-Host "=== Script đã hoàn thành ===" -ForegroundColor Green