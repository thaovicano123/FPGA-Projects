#!/bin/bash
# Script chạy mô phỏng DES Control Unit trên Ubuntu

echo "=== Kiểm tra và cài đặt các công cụ cần thiết ==="
# Kiểm tra Icarus Verilog đã được cài đặt chưa
if ! command -v iverilog &> /dev/null; then
    echo "Icarus Verilog chưa được cài đặt. Đang cài đặt..."
    sudo apt-get update
    sudo apt-get install -y iverilog
else
    echo "Icarus Verilog đã được cài đặt."
fi

# Kiểm tra GTKWave đã được cài đặt chưa
if ! command -v gtkwave &> /dev/null; then
    echo "GTKWave chưa được cài đặt. Đang cài đặt..."
    sudo apt-get update
    sudo apt-get install -y gtkwave
else
    echo "GTKWave đã được cài đặt."
fi

echo "=== Biên dịch các file Verilog ==="
iverilog -o des_control_unit_sim.vvp des_control_unit.v des_control_unit_tb.v

if [ $? -ne 0 ]; then
    echo "Lỗi biên dịch! Kiểm tra lại code của bạn."
    exit 1
fi

echo "=== Chạy mô phỏng ==="
vvp des_control_unit_sim.vvp

echo "=== Mở GTKWave để xem waveform ==="
# Kiểm tra xem file vcd đã được tạo chưa
if [ -f des_control_unit_tb.vcd ]; then
    echo "Đang mở waveform bằng GTKWave..."
    gtkwave des_control_unit_tb.vcd des_wave.gtkw &
else
    echo "Không tìm thấy file waveform."
fi

echo "=== Hoàn thành ==="