# Thiết kế IPcore DES cho ASIC

## Giới thiệu
Dự án này tập trung vào việc thiết kế và triển khai thuật toán mã hóa DES (Data Encryption Standard) trên nền tảng ASIC, với mục đích phát triển một IPcore mã hóa hiệu quả.

## Giới thiệu về DES
DES (Data Encryption Standard) là một thuật toán mã hóa khối đối xứng, phát triển ban đầu bởi IBM vào những năm 1970. Thuật toán này mã hóa dữ liệu theo các khối 64 bit, sử dụng khóa 56 bit (64 bit bao gồm 8 bit chẵn lẻ). Mặc dù đã được thay thế bởi AES trong nhiều ứng dụng hiện đại, DES vẫn là một thuật toán quan trọng trong nghiên cứu và là nền tảng cho nhiều thuật toán mã hóa khác.

## Kiến trúc tổng thể
IPcore DES được thiết kế theo kiến trúc datapath and control, bao gồm:

1. **Control Unit**: Điều khiển luồng thực thi của thuật toán, bao gồm các trạng thái cho:
   - Hoán vị ban đầu (Initial Permutation)
   - Sinh khóa (Key Generation)
   - Các vòng mã hóa (16 rounds)
   - Hoán vị cuối cùng (Final Permutation)

2. **Datapath**: Thực hiện các phép toán trên dữ liệu, bao gồm:
   - Các khối hoán vị (IP, PC-1, PC-2, E, P, IP^-1)
   - Các hộp thay thế (S-boxes)
   - Các phép XOR
   - Xử lý khóa (Key scheduling)

## Control Unit
Control Unit được thiết kế như một máy trạng thái hữu hạn (FSM) để điều khiển quá trình mã hóa/giải mã DES. Chúng tôi đã phát triển hai phiên bản:

### 1. Control Unit Cơ bản
FSM đơn giản với 4 trạng thái:
- IDLE: Chờ tín hiệu start
- INIT: Thực hiện hoán vị ban đầu và chuẩn bị khóa
- ROUNDS: Thực hiện 16 vòng mã hóa
- FINAL: Hoàn thành với hoán vị cuối cùng

### 2. Control Unit Cải tiến
FSM chi tiết hơn với 11+ trạng thái:
- IDLE: Chờ tín hiệu start
- LOAD_DATA: Nạp dữ liệu đầu vào
- INIT_PERM: Hoán vị ban đầu
- KEY_INIT: Khởi tạo khóa
- ROUND_START: Bắt đầu một vòng mới
- KEY_SHIFT: Dịch khóa
- KEY_PERM: Hoán vị khóa
- EXPANSION: Mở rộng khối dữ liệu phải
- XOR_SBOX: XOR với khóa con và thay thế qua S-box
- P_BOX: Hoán vị P-box
- LR_SWAP: Hoán đổi khối trái và phải
- FINAL_PERM: Hoán vị cuối cùng
- COMPLETE: Hoàn thành quá trình mã hóa/giải mã

## Triển khai
Các file mã nguồn chính:

1. **des_control_unit.v**: Phiên bản cơ bản của Control Unit
2. **des_control_unit_improved.v**: Phiên bản cải tiến của Control Unit
3. **des_datapath_and_control.v**: Kết hợp Control Unit và Datapath

## Mô phỏng
Dự án bao gồm các testbench để kiểm tra chức năng của Control Unit:

1. **des_control_unit_tb.v**: Testbench cho phiên bản cơ bản
2. **des_control_unit_improved_tb.v**: Testbench cho phiên bản cải tiến

Để chạy mô phỏng:
1. Trên Linux hoặc WSL:
   ```
   cd sim
   bash run_sim.sh
   ```

2. Trên Windows với WSL:
   ```
   .\run_sim.ps1
   ```

## Xem kết quả waveform
Sau khi chạy mô phỏng, bạn có thể xem kết quả waveform bằng GTKWave:
```
gtkwave sim/des_control_unit_improved.vcd
```

![Waveform của Control Unit](images/control_unit_waveform.png)

## Phân tích và Thiết kế Control Unit
Control Unit trong thiết kế DES đóng vai trò quan trọng trong việc điều khiển luồng xử lý dữ liệu. Thiết kế này sử dụng máy trạng thái hữu hạn (FSM) để theo dõi và kiểm soát các bước trong quá trình mã hóa/giải mã:

1. **Phân tích yêu cầu**: Control Unit cần điều khiển 16 vòng mã hóa, mỗi vòng bao gồm nhiều bước con như sinh khóa con, mở rộng dữ liệu, thay thế qua S-box, hoán vị, và hoán đổi.

2. **Định nghĩa các tín hiệu điều khiển**: Các tín hiệu như `init_perm_en`, `key_shift_en`, `key_perm_en`, `expansion_en`, `xor_en`, `sbox_en`, `p_box_en`, và `lr_swap_en` được định nghĩa để kích hoạt từng khối trong datapath.

3. **Thiết kế FSM**: FSM được thiết kế với các trạng thái riêng biệt cho mỗi bước xử lý, đảm bảo thứ tự thực hiện chính xác và điều khiển thời gian cho mỗi hoạt động.

4. **Bộ đếm vòng**: Một bộ đếm vòng được sử dụng để theo dõi vòng mã hóa hiện tại (0-15) và xác định khi nào quá trình hoàn thành.

5. **Xử lý mã hóa/giải mã**: Control Unit hỗ trợ cả hai chế độ mã hóa và giải mã thông qua tín hiệu `mode`, chủ yếu ảnh hưởng đến thứ tự áp dụng các khóa con.

Thiết kế Control Unit cải tiến đã được kiểm chứng để đảm bảo thứ tự thực hiện chính xác của tất cả các bước trong thuật toán DES.

## Kết luận
Dự án này cung cấp một triển khai đầy đủ của IPcore DES, với trọng tâm vào thiết kế Control Unit. Mã nguồn được tổ chức theo cách cho phép dễ dàng hiểu và mở rộng. Control Unit cải tiến đảm bảo thời gian chính xác cho tất cả các hoạt động trong quá trình mã hóa/giải mã DES.