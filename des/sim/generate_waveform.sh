#!/bin/bash

# Script to generate waveform image for documentation
# Requires Icarus Verilog, GTKWave, and ImageMagick

# Set paths
RTL_DIR="../rtl"
SIM_DIR="."
IMG_DIR="../images"

# Check for required tools
command -v iverilog >/dev/null 2>&1 || { echo "Error: Icarus Verilog not found"; exit 1; }
command -v vvp >/dev/null 2>&1 || { echo "Error: VVP not found"; exit 1; }
command -v gtkwave >/dev/null 2>&1 || { echo "Error: GTKWave not found"; exit 1; }
command -v convert >/dev/null 2>&1 || { echo "Warning: ImageMagick not found, will not convert to PNG"; }

# Compile improved control unit
echo "Compiling improved control unit..."
iverilog -o des_control_unit_improved_tb.vvp $RTL_DIR/des_control_unit_improved.v $SIM_DIR/des_control_unit_improved_tb.v

# Run simulation for improved control unit
echo "Running improved control unit simulation..."
vvp des_control_unit_improved_tb.vvp

# Generate waveform script for GTKWave
echo "Creating GTKWave script..."
cat > gtkwave_script.tcl <<EOF
# GTKWave script to automate waveform capture

# Load the VCD file
gtkwave::loadFile des_control_unit_improved.vcd

# Add all signals from the testbench
set tb_signals [list]
lappend tb_signals des_control_unit_improved_tb.clk
lappend tb_signals des_control_unit_improved_tb.reset
lappend tb_signals des_control_unit_improved_tb.start
lappend tb_signals des_control_unit_improved_tb.mode
lappend tb_signals des_control_unit_improved_tb.ready
lappend tb_signals des_control_unit_improved_tb.round
lappend tb_signals des_control_unit_improved_tb.load_input
lappend tb_signals des_control_unit_improved_tb.store_output
lappend tb_signals des_control_unit_improved_tb.init_perm_en
lappend tb_signals des_control_unit_improved_tb.key_shift_en
lappend tb_signals des_control_unit_improved_tb.key_perm_en
lappend tb_signals des_control_unit_improved_tb.expansion_en
lappend tb_signals des_control_unit_improved_tb.xor_en
lappend tb_signals des_control_unit_improved_tb.sbox_en
lappend tb_signals des_control_unit_improved_tb.p_box_en
lappend tb_signals des_control_unit_improved_tb.lr_swap_en
lappend tb_signals des_control_unit_improved_tb.final_perm_en

# Add all internal signals from the DUT
set dut_signals [list]
lappend dut_signals des_control_unit_improved_tb.dut.state
lappend dut_signals des_control_unit_improved_tb.dut.next_state
lappend dut_signals des_control_unit_improved_tb.dut.round_counter
lappend dut_signals des_control_unit_improved_tb.dut.round_complete

# Add signals to the viewer
set num_added [ gtkwave::addSignalsFromList \$tb_signals ]
set num_added [ gtkwave::addSignalsFromList \$dut_signals ]

# Set zoom to fit
gtkwave::/Time/Zoom/Zoom_Full

# Save the image
gtkwave::setNamedMarker A 0
gtkwave::setNamedMarker B [gtkwave::getMaxTime]
gtkwave::setMarker B
gtkwave::setWindowStartTime A

# Set colors for better visualization
gtkwave::setTraceHighlightFromList "des_control_unit_improved_tb.clk"
gtkwave::setTraceHighlightFromList "des_control_unit_improved_tb.reset"
gtkwave::setTraceHighlightFromList "des_control_unit_improved_tb.start"
gtkwave::highlightSignalsFromList "des_control_unit_improved_tb.clk"
gtkwave::highlightSignalsFromList "des_control_unit_improved_tb.reset"
gtkwave::highlightSignalsFromList "des_control_unit_improved_tb.start"

# Save file and exit
gtkwave::writeFile "$IMG_DIR/waveform_raw.png"
gtkwave::quit
EOF

# Run GTKWave with the script
echo "Generating waveform image..."
gtkwave -S gtkwave_script.tcl des_control_unit_improved.vcd

# Convert the image to a more suitable format if ImageMagick is available
if command -v convert >/dev/null 2>&1; then
    echo "Processing image with ImageMagick..."
    convert $IMG_DIR/waveform_raw.png -trim $IMG_DIR/control_unit_waveform.png
    echo "Waveform image saved to $IMG_DIR/control_unit_waveform.png"
else
    echo "Waveform image saved to $IMG_DIR/waveform_raw.png"
    echo "Install ImageMagick to post-process the image"
fi

# Clean up
rm -f gtkwave_script.tcl

echo "Done!"