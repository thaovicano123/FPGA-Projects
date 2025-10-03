# Makefile for DES IPcore simulation

# Directories
RTL_DIR = ../rtl
SIM_DIR = .

# Source files
SOURCES_BASIC = $(RTL_DIR)/des_control_unit.v $(SIM_DIR)/des_control_unit_tb.v
SOURCES_IMPROVED = $(RTL_DIR)/des_control_unit_improved.v $(SIM_DIR)/des_control_unit_improved_tb.v
SOURCES_FULL = $(RTL_DIR)/des_datapath_and_control.v $(RTL_DIR)/des_control_unit_improved.v

# Output files
VVP_BASIC = des_control_unit_tb.vvp
VVP_IMPROVED = des_control_unit_improved_tb.vvp
VCD_BASIC = des_control_unit.vcd
VCD_IMPROVED = des_control_unit_improved.vcd

# Default target
all: basic improved

# Basic control unit simulation
basic: $(VVP_BASIC)
	vvp $(VVP_BASIC)

# Improved control unit simulation
improved: $(VVP_IMPROVED)
	vvp $(VVP_IMPROVED)

# Compile basic control unit testbench
$(VVP_BASIC): $(SOURCES_BASIC)
	iverilog -o $(VVP_BASIC) $(SOURCES_BASIC)

# Compile improved control unit testbench
$(VVP_IMPROVED): $(SOURCES_IMPROVED)
	iverilog -o $(VVP_IMPROVED) $(SOURCES_IMPROVED)

# View waveform for basic control unit
view_basic: $(VCD_BASIC)
	gtkwave $(VCD_BASIC) &

# View waveform for improved control unit
view_improved: $(VCD_IMPROVED)
	gtkwave $(VCD_IMPROVED) &

# Clean up
clean:
	rm -f *.vvp *.vcd

.PHONY: all basic improved view_basic view_improved clean