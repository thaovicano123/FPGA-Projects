#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script để tự động cập nhật thời gian hiện tại vào file clock_counter.v
Chạy script này trước khi build project để có thời gian chính xác.

Usage: python update_time.py
"""

import datetime
import re
import os

def update_time_in_verilog():
    """Cập nhật thời gian hiện tại vào file clock_counter.v"""
    
    # Lấy thời gian chính xác từ hệ thống (local time)
    now = datetime.datetime.now()
    
    # Thêm một vài giây để bù trừ cho thời gian build và nạp
    # Có thể điều chỉnh offset này nếu cần
    BUILD_OFFSET_SECONDS = 30  # Dự trù 30 giây cho quá trình build + flash
    future_time = now + datetime.timedelta(seconds=BUILD_OFFSET_SECONDS)
    
    hour = future_time.hour
    minute = future_time.minute  
    second = future_time.second
    
    # Hiển thị thông tin chi tiết
    print(f"🕐 Thời gian hiện tại: {now.strftime('%H:%M:%S')}")
    print(f"⏰ Thời gian set cho FPGA: {hour:02d}:{minute:02d}:{second:02d}")
    print(f"   (Đã cộng thêm {BUILD_OFFSET_SECONDS} giây để bù build time)")
    
    # Hiển thị thông tin timezone
    import time
    timezone_offset = time.timezone / 3600
    print(f"🌍 Timezone: UTC{'+' if timezone_offset <= 0 else '-'}{abs(timezone_offset):.0f}")
    
    # Đường dẫn đến file Verilog
    verilog_file = "src/clock_counter.v"
    
    if not os.path.exists(verilog_file):
        print(f"❌ Không tìm thấy file: {verilog_file}")
        return False
    
    try:
        # Đọc nội dung file
        with open(verilog_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern để tìm và thay thế các giá trị khởi tạo
        patterns = [
            (r'localparam INIT_HOUR = 5\'d\d+;', f'localparam INIT_HOUR = 5\'d{hour};'),
            (r'localparam INIT_MIN = 6\'d\d+;', f'localparam INIT_MIN = 6\'d{minute};'),
            (r'localparam INIT_SEC = 6\'d\d+;', f'localparam INIT_SEC = 6\'d{second};')
        ]
        
        # Thay thế từng pattern
        updated_content = content
        for pattern, replacement in patterns:
            updated_content = re.sub(pattern, replacement, updated_content)
        
        # Kiểm tra xem có thay đổi không
        if updated_content != content:
            # Ghi lại file
            with open(verilog_file, 'w', encoding='utf-8') as f:
                f.write(updated_content)
            
            print(f"✅ Đã cập nhật thời gian thành công!")
            print(f"   - Giờ: {hour:02d}")
            print(f"   - Phút: {minute:02d}")
            print(f"   - Giây: {second:02d}")
            return True
        else:
            print("⚠️  Không tìm thấy pattern để cập nhật trong file!")
            return False
            
    except Exception as e:
        print(f"❌ Lỗi khi cập nhật file: {e}")
        return False

def show_current_time_in_file():
    """Hiển thị thời gian hiện tại trong file"""
    verilog_file = "src/clock_counter.v"
    
    if not os.path.exists(verilog_file):
        return
    
    try:
        with open(verilog_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Tìm các giá trị hiện tại
        hour_match = re.search(r'localparam INIT_HOUR = 5\'d(\d+);', content)
        min_match = re.search(r'localparam INIT_MIN = 6\'d(\d+);', content)
        sec_match = re.search(r'localparam INIT_SEC = 6\'d(\d+);', content)
        
        if hour_match and min_match and sec_match:
            hour = int(hour_match.group(1))
            minute = int(min_match.group(1))
            second = int(sec_match.group(1))
            print(f"📋 Thời gian trong file: {hour:02d}:{minute:02d}:{second:02d}")
        
    except Exception as e:
        print(f"❌ Lỗi khi đọc file: {e}")

def manual_time_input():
    """Cho phép người dùng nhập thời gian thủ công"""
    print("\n🕐 Nhập thời gian thủ công:")
    
    try:
        hour = int(input("   Giờ (0-23): "))
        minute = int(input("   Phút (0-59): "))
        second = int(input("   Giây (0-59): "))
        
        # Validate input
        if not (0 <= hour <= 23 and 0 <= minute <= 59 and 0 <= second <= 59):
            print("❌ Thời gian không hợp lệ!")
            return None
            
        return hour, minute, second
        
    except ValueError:
        print("❌ Vui lòng nhập số!")
        return None

def update_time_manual(hour, minute, second):
    """Cập nhật thời gian thủ công vào file"""
    verilog_file = "src/clock_counter.v"
    
    print(f"⏰ Thời gian set cho FPGA: {hour:02d}:{minute:02d}:{second:02d}")
    
    if not os.path.exists(verilog_file):
        print(f"❌ Không tìm thấy file: {verilog_file}")
        return False
    
    try:
        # Đọc nội dung file
        with open(verilog_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Pattern để tìm và thay thế các giá trị khởi tạo
        patterns = [
            (r'localparam INIT_HOUR = 5\'d\d+;', f'localparam INIT_HOUR = 5\'d{hour};'),
            (r'localparam INIT_MIN = 6\'d\d+;', f'localparam INIT_MIN = 6\'d{minute};'),
            (r'localparam INIT_SEC = 6\'d\d+;', f'localparam INIT_SEC = 6\'d{second};')
        ]
        
        # Thay thế từng pattern
        updated_content = content
        for pattern, replacement in patterns:
            updated_content = re.sub(pattern, replacement, updated_content)
        
        # Ghi lại file
        with open(verilog_file, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        
        print(f"✅ Đã cập nhật thời gian thành công!")
        return True
        
    except Exception as e:
        print(f"❌ Lỗi khi cập nhật file: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Script cập nhật thời gian cho FPGA Clock")
    print("=" * 45)
    
    # Hiển thị thời gian hiện tại trong file
    show_current_time_in_file()
    
    # Lựa chọn chế độ
    print("\n📋 Chọn chế độ cập nhật:")
    print("   1. Tự động lấy thời gian hiện tại (có offset)")
    print("   2. Nhập thời gian thủ công")
    
    choice = input("\nNhập lựa chọn (1 hoặc 2): ").strip()
    
    success = False
    
    if choice == "1":
        # Cập nhật thời gian tự động
        success = update_time_in_verilog()
    elif choice == "2":
        # Cập nhật thời gian thủ công
        manual_time = manual_time_input()
        if manual_time:
            hour, minute, second = manual_time
            success = update_time_manual(hour, minute, second)
    else:
        print("❌ Lựa chọn không hợp lệ!")
    
    if success:
        print("\n🎯 Hướng dẫn tiếp theo:")
        print("   1. Build project trong Gowin IDE")
        print("   2. Nạp bitstream vào Tang Nano 4K")
        print("   3. Reset board để áp dụng thời gian mới")
        print("\n⏰ Đồng hồ sẽ bắt đầu từ thời gian đã set!")
    else:
        print("\n❌ Cập nhật thất bại. Vui lòng thử lại.") 