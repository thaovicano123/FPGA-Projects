# Phân tích và Thiết kế Control Unit cho DES

## 1. Giới thiệu

Control Unit là một thành phần quan trọng trong kiến trúc DES IPcore, đóng vai trò điều khiển luồng xử lý và thời gian của các hoạt động mã hóa. Tài liệu này trình bày chi tiết quá trình phân tích và thiết kế Control Unit cho DES.

## 2. Yêu cầu và Đặc điểm kỹ thuật

### 2.1 Yêu cầu chức năng
Control Unit cần thực hiện các chức năng sau:
- Điều khiển quá trình hoán vị ban đầu (Initial Permutation)
- Điều khiển việc sinh khóa cho mỗi vòng
- Điều khiển thứ tự thực hiện các vòng mã hóa (16 rounds)
- Điều khiển quá trình hoán vị cuối cùng (Final Permutation)
- Cung cấp tín hiệu báo trạng thái (ready, done) cho hệ thống
- Hỗ trợ cả hai chế độ mã hóa và giải mã

### 2.2 Tính năng cụ thể
- Tạo ra các tín hiệu điều khiển cho từng giai đoạn xử lý
- Đếm và theo dõi vòng hiện tại (0-15)
- Quản lý chuyển đổi giữa các trạng thái xử lý
- Xử lý tín hiệu reset và start từ bên ngoài

## 3. Phân tích Thuật toán DES và Yêu cầu Điều khiển

### 3.1 Phân tích quy trình DES
Thuật toán DES thực hiện các bước sau:
1. **Hoán vị ban đầu (IP)**: Sắp xếp lại 64 bit dữ liệu đầu vào
2. **Xử lý vòng** (16 vòng):
   - Tạo khóa con cho vòng hiện tại từ khóa chính
   - Mở rộng khối phải 32 bit thành 48 bit (E)
   - XOR khối mở rộng với khóa con
   - Chuyển đổi qua 8 hộp S (S-box)
   - Hoán vị kết quả (P)
   - XOR kết quả với khối trái
   - Hoán đổi khối trái và phải (ngoại trừ vòng cuối)
3. **Hoán vị cuối cùng (IP^-1)**: Đảo ngược hoán vị ban đầu

### 3.2 Phân tích yêu cầu điều khiển
Từ phân tích thuật toán, chúng ta xác định các yêu cầu điều khiển sau:
- Khởi tạo hoạt động khi nhận tín hiệu start
- Tạo và quản lý các tín hiệu điều khiển cho từng bước
- Đếm và theo dõi vòng hiện tại
- Điều khiển sự chuyển đổi giữa các trạng thái
- Đảm bảo thời gian chính xác cho mỗi hoạt động
- Phát hiện hoàn thành và đưa ra tín hiệu ready

## 4. Thiết kế FSM (Máy trạng thái hữu hạn)

### 4.1 Phương pháp thiết kế
Chúng tôi chọn thiết kế FSM theo mô hình Mealy, trong đó đầu ra phụ thuộc vào cả trạng thái hiện tại và đầu vào. Các đầu ra của FSM là các tín hiệu điều khiển cho các khối chức năng trong datapath.

### 4.2 Trạng thái FSM
Trong phiên bản cải tiến, chúng tôi xác định các trạng thái sau:
- **IDLE**: Trạng thái chờ, ready=1
- **LOAD_DATA**: Nạp dữ liệu đầu vào
- **INIT_PERM**: Thực hiện hoán vị ban đầu
- **KEY_INIT**: Khởi tạo khóa (PC-1)
- **ROUND_START**: Bắt đầu một vòng mới
- **KEY_SHIFT**: Dịch khóa trái/phải tùy theo vòng
- **KEY_PERM**: Hoán vị khóa (PC-2)
- **EXPANSION**: Mở rộng khối phải 32-bit thành 48-bit
- **XOR_SBOX**: XOR với khóa con và chuyển qua S-box
- **P_BOX**: Hoán vị P-box
- **LR_SWAP**: Hoán đổi khối trái và phải
- **FINAL_PERM**: Hoán vị cuối cùng
- **COMPLETE**: Hoàn thành, đặt ready=1

### 4.3 Chuyển đổi trạng thái
Các chuyển đổi trạng thái được xác định dựa trên logic sau:
- IDLE → LOAD_DATA: Khi start=1
- LOAD_DATA → INIT_PERM: Sau 1 chu kỳ clock
- INIT_PERM → KEY_INIT: Sau 1 chu kỳ clock
- KEY_INIT → ROUND_START: Sau 1 chu kỳ clock
- ROUND_START → KEY_SHIFT: Sau 1 chu kỳ clock
- KEY_SHIFT → KEY_PERM: Sau 1 chu kỳ clock
- KEY_PERM → EXPANSION: Sau 1 chu kỳ clock
- EXPANSION → XOR_SBOX: Sau 1 chu kỳ clock
- XOR_SBOX → P_BOX: Sau 1 chu kỳ clock
- P_BOX → FINAL_PERM: Nếu round=15, kết thúc vòng cuối
- P_BOX → LR_SWAP: Nếu round<15, cần vòng tiếp theo
- LR_SWAP → ROUND_START: Sau 1 chu kỳ clock, tăng round
- FINAL_PERM → COMPLETE: Sau 1 chu kỳ clock
- COMPLETE → IDLE: Sau 1 chu kỳ clock

### 4.4 Tín hiệu đầu ra
Mỗi trạng thái sẽ kích hoạt các tín hiệu điều khiển cần thiết:
- **IDLE**: ready=1
- **LOAD_DATA**: load_input=1
- **INIT_PERM**: init_perm_en=1
- **KEY_INIT**: key_perm_en=1
- **KEY_SHIFT**: key_shift_en=1
- **KEY_PERM**: key_perm_en=1
- **EXPANSION**: expansion_en=1
- **XOR_SBOX**: xor_en=1, sbox_en=1
- **P_BOX**: p_box_en=1
- **LR_SWAP**: lr_swap_en=1
- **FINAL_PERM**: final_perm_en=1
- **COMPLETE**: store_output=1, ready=1

## 5. Triển khai Control Unit

### 5.1 Cấu trúc mã
Control Unit được triển khai trong ngôn ngữ Verilog với ba khối chính:
1. **Logic trạng thái**: Đăng ký trạng thái và logic chuyển đổi trạng thái kế tiếp
2. **Bộ đếm vòng**: Theo dõi vòng hiện tại (0-15)
3. **Logic đầu ra**: Tạo tín hiệu điều khiển dựa trên trạng thái hiện tại

### 5.2 Phương pháp chống hazard và lỗi thời gian
- Tất cả các đầu ra được đăng ký (registered outputs) để tránh glitches
- Sử dụng reset đồng bộ để đảm bảo khởi tạo chính xác
- Các trạng thái được thiết kế để tránh xung đột giữa các tín hiệu điều khiển

### 5.3 Xử lý mã hóa và giải mã
- Chế độ giải mã được hỗ trợ bằng cách đảo ngược thứ tự áp dụng các khóa con
- Trong chế độ mã hóa (mode=0): Sử dụng khóa theo thứ tự K1, K2, ..., K16
- Trong chế độ giải mã (mode=1): Sử dụng khóa theo thứ tự K16, K15, ..., K1

## 6. Kiểm tra và Xác nhận

### 6.1 Phương pháp kiểm tra
Control Unit được kiểm tra bằng cách sử dụng các testbench để mô phỏng hoạt động:
- Kiểm tra reset đúng
- Kiểm tra trình tự trạng thái
- Kiểm tra các tín hiệu điều khiển
- Kiểm tra bộ đếm vòng
- Kiểm tra chế độ mã hóa/giải mã

### 6.2 Kết quả kiểm tra
Các kết quả mô phỏng xác nhận rằng:
- Control Unit chuyển đổi giữa các trạng thái đúng thời gian
- Các tín hiệu điều khiển được tạo ra chính xác
- Bộ đếm vòng hoạt động chính xác
- Mỗi vòng mã hóa được thực hiện đúng trình tự
- Cả hai chế độ mã hóa và giải mã hoạt động chính xác

### 6.3 Phân tích waveform
Phân tích waveform cho thấy:
- Không có glitches trong các tín hiệu điều khiển
- Thời gian chính xác giữa các trạng thái
- Thời gian chuyển đổi trạng thái phù hợp với thiết kế

## 7. Cải tiến và Phát triển tiếp theo

### 7.1 Cải tiến hiệu suất
Có thể cải thiện hiệu suất bằng cách:
- Tối ưu hóa số trạng thái
- Thực hiện các hoạt động song song khi có thể
- Tạo pipeline cho quá trình xử lý

### 7.2 Tính năng bổ sung
Các tính năng có thể bổ sung:
- Hỗ trợ Triple DES (3DES)
- Thêm chế độ tiết kiệm năng lượng
- Thêm hỗ trợ cho các chế độ mã hóa khác (CBC, CFB, OFB)

## 8. Kết luận

Thiết kế Control Unit cho DES đã được phân tích chi tiết và triển khai thành công. Phiên bản cải tiến cung cấp điều khiển chi tiết hơn cho từng bước trong thuật toán DES, đảm bảo thời gian chính xác và hoạt động đáng tin cậy. Mã nguồn được tổ chức tốt và có thể dễ dàng mở rộng cho các tính năng bổ sung trong tương lai.

Các thử nghiệm và mô phỏng xác nhận rằng Control Unit hoạt động như mong đợi và có thể được tích hợp vào IPcore DES hoàn chỉnh.