# Control Unit cho IPcore DES trên ASIC

Dự án này tập trung vào việc thiết kế và triển khai Control Unit (Bộ điều khiển) cho IPcore DES (Data Encryption Standard) trên ASIC (Application-Specific Integrated Circuit). Control Unit là thành phần trung tâm điều khiển hoạt động của toàn bộ thuật toán mã hóa, quản lý trạng thái hệ thống và sinh tín hiệu điều khiển cho các khối datapath.

## 📑 Mục lục
- [Tổng quan](#tổng-quan)
- [Module Control Unit](#module-control-unit)
- [Chức năng chính](#chức-năng-chính)
- [Cải tiến Control Unit](#cải-tiến-control-unit)
- [Kết quả mô phỏng](#kết-quả-mô-phỏng)
- [Lộ trình hoàn thiện DES](#lộ-trình-hoàn-thiện-des)
- [Công cụ sử dụng](#công-cụ-sử-dụng)
- [Hướng dẫn chạy mô phỏng](#hướng-dẫn-chạy-mô-phỏng)
- [Tài liệu tham khảo](#tài-liệu-tham-khảo)

## 📝 Tổng quan

DES (Data Encryption Standard) là thuật toán mã hóa đối xứng cổ điển, sử dụng khóa 56-bit để mã hóa dữ liệu 64-bit. Mặc dù không còn được sử dụng rộng rãi cho các ứng dụng bảo mật hiện đại, DES vẫn là nền tảng cho nhiều thuật toán mã hóa và là đối tượng nghiên cứu học thuật quan trọng.

Dự án này tập trung vào việc thiết kế Control Unit - "bộ não" điều khiển cho toàn bộ quá trình mã hóa/giải mã DES trên ASIC. Control Unit điều phối hoạt động của các khối chức năng, quản lý trạng thái, và đảm bảo tuần tự xử lý chính xác.

## 🔄 Module Control Unit

Control Unit được thiết kế theo kiến trúc FSM (Finite State Machine), quản lý các trạng thái và sinh tín hiệu điều khiển cho toàn bộ hệ thống DES. Module này thực hiện:

### Ports chính:
- **Inputs**: `clk`, `rst_n`, `start`, `key_ready`, `data_ready`
- **Outputs**: 
  - Tín hiệu trạng thái: `done`, `error`, `round_count[4:0]`, `state[3:0]`
  - Tín hiệu điều khiển datapath: `en_ip`, `en_fp`, `en_expansion`, `en_key_mixing`, `en_sbox`, `en_pbox`, `en_feistel`, `en_key_schedule`
  - Tín hiệu chọn dữ liệu: `sel_input`, `sel_output`

### Các trạng thái FSM (trong phiên bản cải tiến):
- `IDLE`: Chờ lệnh start
- `INIT_PERM`: Thực hiện Initial Permutation
- `KEY_SCHEDULE`: Tính toán key schedule cho vòng hiện tại
- `EXPANSION`: Thực hiện expansion
- `KEY_MIXING`: XOR với subkey
- `SBOX`: Thực hiện S-box
- `PBOX`: Thực hiện P-box
- `FEISTEL`: Hoàn thành vòng Feistel
- `FINAL_PERM`: Thực hiện Final Permutation
- `DONE_STATE`: Hoàn thành xử lý
- `ERROR_STATE`: Trạng thái lỗi

## 🔍 Chức năng chính

### 1. Quản lý trạng thái hệ thống:
- Theo dõi và chuyển đổi giữa các trạng thái hoạt động: IDLE (chờ), RUN (đang xử lý), DONE (hoàn thành), ERROR (lỗi)
- Thực hiện máy trạng thái hữu hạn (FSM) để quản lý luồng xử lý theo tuần tự

### 2. Điều khiển 16 vòng lặp DES:
- Tạo và quản lý bộ đếm vòng lặp (từ 1 đến 16)
- Đảm bảo các vòng được thực hiện tuần tự theo đúng thuật toán DES
- Sinh khóa con tương ứng cho từng vòng

### 3. Sinh tín hiệu điều khiển cho các khối datapath:
- Tạo tín hiệu enable/disable cho các khối xử lý dữ liệu (IP, FP, Expansion, S-boxes, P-box, v.v.)
- Điều khiển thời điểm hoạt động của từng khối để đảm bảo timing chính xác
- Quản lý chọn dữ liệu đầu vào/ra (mux control signals)

### 4. Xử lý tín hiệu điều khiển bên ngoài:
- Phản hồi với tín hiệu start để bắt đầu quá trình mã hóa/giải mã
- Sinh tín hiệu done khi hoàn thành xử lý
- Phát hiện và báo hiệu lỗi (error) khi có sự cố

## 📈 Cải tiến Control Unit

Module `des_control_unit_improved.v` cải tiến từ phiên bản ban đầu với những ưu điểm:

- **FSM chi tiết hơn**: Sử dụng 11 trạng thái thay vì 4 trạng thái, phân tách rõ từng bước xử lý
- **Điều khiển chính xác timing**: Mỗi bước trong thuật toán DES được điều khiển riêng biệt
- **Kích hoạt từng khối tại thời điểm chính xác**: Mỗi khối datapath chỉ được kích hoạt khi cần thiết
- **Tuân thủ đúng quy trình DES**: Thứ tự xử lý IDLE → INIT_PERM → KEY_SCHEDULE → EXPANSION → KEY_MIXING → SBOX → PBOX → FEISTEL → (lặp lại từ KEY_SCHEDULE) → FINAL_PERM → DONE
- **Xử lý lỗi hoàn thiện**: Phát hiện lỗi khi start mà key hoặc data chưa sẵn sàng

## 📊 Kết quả mô phỏng

Mô phỏng Control Unit đã xác nhận hoạt động đúng đắn với các chức năng:

### 1. Luồng trạng thái (FSM) đúng chuẩn DES:
- Module tuần tự đi qua các trạng thái theo đúng chuẩn DES
- Thứ tự xử lý chính xác theo thuật toán

### 2. Bộ đếm vòng lặp:
- Tăng từ 1 đến 16 tại đúng thời điểm (vào đầu mỗi vòng)
- Giữ nguyên giá trị trong các trạng thái của một vòng
- Chính xác vòng thứ 16 trước khi thực hiện Final Permutation

### 3. Tín hiệu điều khiển:
- Mỗi tín hiệu điều khiển chỉ được kích hoạt trong trạng thái tương ứng
- Timing chính xác đảm bảo luồng dữ liệu đúng

### 4. Xử lý lỗi:
- Phát hiện khi start được kích hoạt nhưng key hoặc data chưa sẵn sàng
- Chuyển sang trạng thái ERROR và kích hoạt tín hiệu error
- Có thể khôi phục khi điều kiện được đáp ứng

### 5. Timing chính xác:
- Mỗi bước xử lý được thực hiện trong một chu kỳ đồng hồ
- Không có các bước xử lý đồng thời không phù hợp
- Bộ đếm vòng lặp được tăng tại thời điểm chính xác

## 🛣️ Lộ trình hoàn thiện DES

Để hoàn thiện toàn bộ thiết kế DES dựa trên Control Unit đã có, cần thực hiện các bước sau:

### 1. Phát triển các khối Datapath:
- **Initial Permutation (IP)**: Hoán vị ban đầu 64-bit theo bảng IP
- **Expansion (E)**: Mở rộng 32-bit thành 48-bit theo bảng E
- **Key Schedule**: Tạo 16 khóa con 48-bit từ khóa chính 64-bit
- **S-boxes**: 8 bảng thay thế chuyển đổi 48-bit thành 32-bit
- **P-box**: Hoán vị 32-bit theo bảng P
- **Feistel Network**: Xử lý 2 nửa dữ liệu và thực hiện phép XOR
- **Final Permutation (FP)**: Hoán vị cuối cùng (ngược với IP)

### 2. Tích hợp các khối thành module DES đầy đủ:
- Kết nối Control Unit với các khối Datapath
- Xây dựng các đường dẫn dữ liệu (data path)
- Tạo hệ thống mux để chọn dữ liệu đầu vào/ra
- Thiết kế tích hợp hỗ trợ cả mã hóa và giải mã

### 3. Tạo testbench để kiểm tra:
- Sử dụng các vector test DES chuẩn
- Kiểm tra quá trình mã hóa: plaintext → ciphertext
- Kiểm tra quá trình giải mã: ciphertext → plaintext
- Xác nhận kết quả đúng theo chuẩn DES

### 4. Tối ưu hóa cho ASIC:
- **Pipeline**: Chia các vòng thành nhiều stages để tăng throughput
- **Parallelization**: Xử lý nhiều khối dữ liệu song song
- **Tối ưu mức cổng logic**: Giảm diện tích, tăng tốc độ
- **Phân tích timing và power**: Đáp ứng các ràng buộc thiết kế

### 5. Tạo tài liệu IPcore:
- Đặc tả chức năng và interface
- Hướng dẫn tích hợp
- Báo cáo hiệu năng
- Kết quả synthesis trên ASIC

## 🔧 Công cụ sử dụng

- **Mô phỏng**: ModelSim/Questa, Icarus Verilog
- **Tổng hợp**: Synopsys Design Compiler, Cadence Genus
- **Phân tích**: Synopsys PrimeTime, Cadence Tempus
- **Kiểm tra**: OpenVera, SystemVerilog testbench, UVM

## 📖 Hướng dẫn chạy mô phỏng

Dự án bao gồm một số script để hỗ trợ quá trình mô phỏng:

### Chạy mô phỏng Control Unit:
```bash
# Sử dụng Icarus Verilog trên Ubuntu/WSL
cd /path/to/des
./run_sim_ubuntu.sh

# Sử dụng ModelSim (Windows)
.\run_modelsim.bat
```

### Xem kết quả waveform:
```bash
# Sử dụng GTKWave trên Ubuntu/WSL
gtkwave des_control_unit_improved_tb.vcd des_wave_improved.gtkw

# Hoặc sử dụng script tự động
.\run_simulation_and_gtkwave.bat
```

#### Hình ảnh waveform của Control Unit:

![DES Control Unit Waveform](./images/des_control_unit_waveform.png)

*Hình: Waveform hiển thị các tín hiệu của DES Control Unit trong GTKWave, bao gồm tín hiệu clock (clk), các tín hiệu điều khiển (start, key_ready, data_ready), trạng thái (state), bộ đếm vòng lặp (round_count), và các tín hiệu enable cho các khối datapath.*

### Lưu ý quan trọng:
Control Unit chỉ là một phần điều khiển của thuật toán DES, không trực tiếp xử lý dữ liệu đầu vào/đầu ra của quá trình mã hóa/giải mã. Để xem được dữ liệu khi đi qua quá trình encryption và decryption, cần phát triển thêm các khối datapath và tích hợp với Control Unit.

## 📚 Tài liệu tham khảo

1. "FIPS 46-3: Data Encryption Standard (DES)" - National Institute of Standards and Technology
2. "Cryptographic Engineering: Principles and Practical Applications" - Cetin K. Koc
3. "FPGA Designs for Digital Signal Processing" - Donald G. Bailey
4. "ASIC Design and Verification: A Guide to Digital ASIC Design Flow" - S.K. Mitra

## 👨‍💻 Đóng góp

Dự án này là một phần của nghiên cứu khoa học về thiết kế IPcore sử dụng DES trên ASIC. Mọi đóng góp và góp ý đều được đánh giá cao.

## 📄 Giấy phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.