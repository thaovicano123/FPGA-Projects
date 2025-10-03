# ModelSim/Questa TCL script cho DES Control Unit

# Tạo thư mục làm việc
vlib work

# Biên dịch các module
vlog -work work des_control_unit.v
vlog -work work des_control_unit_tb.v

# Bắt đầu mô phỏng
vsim -t 1ns -voptargs=+acc work.des_control_unit_tb

# Thêm các tín hiệu để hiển thị trên wave window
add wave -position insertpoint \
sim:/des_control_unit_tb/clk \
sim:/des_control_unit_tb/rst_n \
sim:/des_control_unit_tb/start \
sim:/des_control_unit_tb/key_ready \
sim:/des_control_unit_tb/data_ready \
sim:/des_control_unit_tb/done \
sim:/des_control_unit_tb/error \
sim:/des_control_unit_tb/round_count \
sim:/des_control_unit_tb/state \
sim:/des_control_unit_tb/en_ip \
sim:/des_control_unit_tb/en_fp \
sim:/des_control_unit_tb/en_expansion \
sim:/des_control_unit_tb/en_key_mixing \
sim:/des_control_unit_tb/en_sbox \
sim:/des_control_unit_tb/en_pbox \
sim:/des_control_unit_tb/en_feistel \
sim:/des_control_unit_tb/en_key_schedule \
sim:/des_control_unit_tb/sel_input \
sim:/des_control_unit_tb/sel_output

# Chạy mô phỏng trong 300ns
run 300ns

# Zoom để hiển thị toàn bộ waveform
wave zoom full