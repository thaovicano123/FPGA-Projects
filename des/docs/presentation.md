# Thiết kế IPcore DES trên ASIC
## Phân tích và Thiết kế Control Unit

---

## Nội dung

1. Giới thiệu về DES
2. Kiến trúc tổng thể IPcore DES
3. Phân tích yêu cầu Control Unit
4. Thiết kế Control Unit
5. Kết quả mô phỏng
6. Kết luận

---

## 1. Giới thiệu về DES

- **DES (Data Encryption Standard)**
  - Thuật toán mã hóa khối đối xứng
  - Phát triển bởi IBM, chuẩn hóa năm 1977
  - Khối 64-bit, khóa 56-bit
  - 16 vòng mã hóa giống nhau
  - Vẫn được sử dụng trong nhiều hệ thống cũ

- **Cấu trúc thuật toán DES**
  - Hoán vị ban đầu (IP)
  - 16 vòng mã hóa với các khóa con
  - Hoán vị cuối cùng (IP^-1)

---

## 2. Kiến trúc tổng thể IPcore DES

- **Kiến trúc Datapath and Control**
  - Control Unit: FSM, điều khiển luồng xử lý
  - Datapath: Thực hiện các phép toán dữ liệu

- **Các khối chức năng**
  - Initial Permutation
  - Final Permutation
  - Key Schedule
  - Round Function (f-function)
  - S-boxes
  - P-box

---

## 3. Phân tích yêu cầu Control Unit

- **Yêu cầu chức năng**
  - Điều khiển thứ tự thực hiện các hoạt động
  - Theo dõi và quản lý 16 vòng mã hóa
  - Tạo tín hiệu điều khiển cho các khối chức năng
  - Hỗ trợ mã hóa và giải mã

- **Yêu cầu về thời gian**
  - Đảm bảo thời gian chính xác cho mỗi thao tác
  - Tuần tự hóa các hoạt động

---

## 4. Thiết kế Control Unit

- **Phương pháp thiết kế FSM**
  - FSM kiểu Mealy
  - Đầu ra phụ thuộc vào trạng thái và đầu vào

- **Các trạng thái chính**
  - IDLE: Chờ tín hiệu start
  - INIT_PERM: Hoán vị ban đầu
  - KEY_* states: Xử lý khóa
  - ROUND_* states: Thực hiện các vòng
  - FINAL_PERM: Hoán vị cuối cùng
  - COMPLETE: Hoàn thành

- **Tín hiệu điều khiển**
  - load_input, store_output
  - init_perm_en, final_perm_en
  - key_shift_en, key_perm_en
  - expansion_en, xor_en, sbox_en, p_box_en
  - lr_swap_en

---

## 5. Kết quả mô phỏng

- **Kết quả FSM**
  - Chuyển đổi trạng thái chính xác
  - Đếm vòng đúng
  - Tín hiệu điều khiển đúng thời gian

- **Waveform**
  - [Hình ảnh waveform từ mô phỏng]

- **Mã hóa/giải mã**
  - Hoạt động chính xác trong cả hai chế độ
  - Thứ tự khóa đảo ngược trong chế độ giải mã

---

## 6. Kết luận

- **Đóng góp**
  - Control Unit hoạt động đúng yêu cầu
  - Hỗ trợ đầy đủ các thao tác DES
  - Kiểm chứng bằng mô phỏng

- **Phát triển tiếp theo**
  - Tối ưu hóa hiệu suất
  - Triển khai datapath đầy đủ
  - Tích hợp với các thành phần khác

---

## Câu hỏi & Thảo luận

[Phần này dành cho câu hỏi và thảo luận]