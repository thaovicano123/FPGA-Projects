# 🕐 HƯỚNG DẪN NẠP FPGA VỚI THỜI GIAN CHÍNH XÁC

## 🔄 QUY TRÌNH MỖI LẦN NẠP

### **Bước 1: Cập nhật thời gian (BẮT BUỘC)**
```bash
# Mở Command Prompt tại thư mục project
cd "D:\GOWIN_MCU_SONIX\VONG_LOAI\Bai_1\RTC_Clock_Display"

# Chạy script cập nhật thời gian
update_time_simple.bat
```

**Hoặc có thể:**
- Double-click vào file `update_time_simple.bat`
- Chọn [Y] để tự động cập nhật với thời gian hiện tại + 30s offset
- Chọn [M] để nhập thời gian thủ công

### **Bước 2: Build Project (Ngay lập tức)**
1. Mở **Gowin EDA IDE**
2. Mở project `RTC_Clock_Display.gprj`
3. Nhấn **Process** → **Place & Route** (hoặc Ctrl+R)
4. Đợi build hoàn thành (~30 giây)

### **Bước 3: Nạp Bitstream**
1. Kết nối Tang Nano 4K qua USB
2. Nhấn **Tools** → **Programmer**
3. Chọn file `.fs` đã build
4. Nhấn **Program/Configure** để nạp
5. Đợi nạp hoàn thành (~10 giây)

### **Bước 4: Reset và kiểm tra**
1. **Nhấn nút reset** trên Tang Nano 4K
2. **Kiểm tra màn hình HDMI** - đồng hồ sẽ hiển thị thời gian chính xác!

---

## ⚡ **Workflow nhanh (2 phút)**

```bash
# 1. Cập nhật thời gian (5 giây)
update_time_simple.bat → [Y]

# 2. Build trong IDE (30 giây)  
Ctrl+R → Đợi build xong

# 3. Nạp bitstream (10 giây)
Tools → Programmer → Program

# 4. Reset board (1 giây)
Nhấn nút reset
```

**Tổng thời gian: ~45 giây**

---

## 🎯 **Lưu ý quan trọng**

### **Timing rất quan trọng:**
- Script có **offset +30 giây** để bù thời gian build
- Nếu build + nạp quá 30 giây → đồng hồ sẽ nhanh vài giây
- Nếu muốn chính xác tuyệt đối → chọn [M] và nhập thời gian thủ công

### **Khi nào cần cập nhật:**
- ✅ **Mỗi lần mở project mới**
- ✅ **Sau khi máy tính sleep/hibernate**  
- ✅ **Khi muốn sync lại thời gian**
- ❌ **Không cần khi chỉ thay đổi code khác (màu sắc, hiệu ứng)**

### **Troubleshooting:**
- **Đồng hồ sai vài giây:** Build quá lâu, lần sau nhập thời gian thủ công
- **Đồng hồ không đếm:** Kiểm tra reset board
- **Hiển thị 00:00:00:** File chưa được cập nhật, chạy lại script

---

## 🛠️ **Advanced: Script tùy chỉnh**

Nếu muốn offset khác 30 giây, sửa trong `update_time_simple.bat`:
```batch
REM Add offset seconds (thay đổi số này)
set /a "OFFSET_SEC=%SECOND%+45"  # 45 giây thay vì 30
```

---

## 📝 **Checklist nhanh**

- [ ] Chạy `update_time_simple.bat`
- [ ] Build project (Ctrl+R)
- [ ] Nạp bitstream 
- [ ] Reset board
- [ ] Kiểm tra thời gian trên màn hình ✅ 