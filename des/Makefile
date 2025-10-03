# Makefile cho DES Control Unit

# Tên file output
TARGET = des_control_unit_sim

# Tool và flags
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
IVERILOG_FLAGS = -Wall -g2012

# Source files
SOURCES = des_control_unit.v des_control_unit_tb.v

# Mặc định target
all: sim

# Biên dịch
compile: $(SOURCES)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(TARGET).vvp $(SOURCES)

# Chạy mô phỏng
sim: compile
	$(VVP) $(TARGET).vvp

# Mở GTKWave
wave: sim
	$(GTKWAVE) des_control_unit_tb.vcd des_wave.gtkw &

# Dọn dẹp
clean:
	rm -f *.vvp *.vcd

.PHONY: all compile sim wave clean