#!/bin/bash

# Script to compile and simulate DES control unit designs

# Set paths
RTL_DIR="../rtl"
SIM_DIR="."

# Compile basic control unit
echo "Compiling basic control unit..."
iverilog -o des_control_unit_tb.vvp $RTL_DIR/des_control_unit.v $SIM_DIR/des_control_unit_tb.v

# Run simulation for basic control unit
echo "Running basic control unit simulation..."
vvp des_control_unit_tb.vvp

# Compile improved control unit
echo "Compiling improved control unit..."
iverilog -o des_control_unit_improved_tb.vvp $RTL_DIR/des_control_unit_improved.v $SIM_DIR/des_control_unit_improved_tb.v

# Run simulation for improved control unit
echo "Running improved control unit simulation..."
vvp des_control_unit_improved_tb.vvp

# Generate waveform
echo "Generating waveform..."
# Uncomment to open waveform immediately
# gtkwave des_control_unit_improved.vcd &

echo "Simulations complete!"