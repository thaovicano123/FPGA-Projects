# Button Counter Display Project

This project was converted from the original RTC_Clock_Display project to focus on button counter functionality.

## Project Structure

- `src/` - Contains all Verilog source files and constraint files
- `impl/` - Contains implementation folders for synthesis and place-and-route
- `Button_Counter_Display.gprj` - Main project file for Gowin IDE

## How to Build

1. Open `Button_Counter_Display.gprj` in Gowin IDE
2. Run the synthesis and place-and-route process
3. Program the FPGA with the generated bitstream

## Batch Files

- `CLEAN_AND_REBUILD.bat` - Cleans implementation folders and prepares for a fresh build
- `QUICK_UPDATE.bat` - Updates the counter display settings

## Source Files

- `clock_counter.v` - Main counter logic
- `font_rom.v` - Font data for display
- `text_renderer_enhanced.v` - Text rendering module
- `top.v` - Top-level module connecting all components
- Other supporting files for clocks, reset, and video timing

## Notes

This project was converted from RTC_Clock_Display on July 10, 2025.
