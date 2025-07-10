# Dual LED Controller Project

This project was converted from the Button_Counter_Display project to add dual LED control functionality.

## Project Features

- Real-time clock display (HH:MM:SS)
- Button-controlled counter display
- Dual LED control:
  - LED1 (MODE/LED1 - Pin 10): Blinks with the clock counter (1Hz)
  - LED2 (LED2 - Pin 13): Blinks when button is pressed (5Hz)
- HDMI output for display

## Project Structure

- `src/` - Contains all Verilog source files and constraint files
- `impl/` - Contains implementation folders for synthesis and place-and-route
- `Dual_LED_Controller.gprj` - Main project file for Gowin IDE

## How to Build

1. Open `Dual_LED_Controller.gprj` in Gowin IDE
2. Run the synthesis and place-and-route process
3. Program the FPGA with the generated bitstream

## Batch Files

- `CLEAN_AND_REBUILD.bat` - Cleans implementation folders and prepares for a fresh build
- `QUICK_UPDATE.bat` - Updates the counter display settings

## Source Files

- `clock_counter.v` - Main counter logic and button debounce
- `font_rom.v` - Font data for display
- `text_renderer_enhanced.v` - Text rendering module with LED status display
- `top.v` - Top-level module connecting all components and LED control logic
- Other supporting files for clocks, reset, and video timing

## Hardware Requirements

- Gowin FPGA Development Board (GW1NSR-4C)
- HDMI Display
- Two LEDs connected to pins 10 and 13

## Notes

This project was upgraded from Button_Counter_Display on July 10, 2025 to add LED control functionality.
