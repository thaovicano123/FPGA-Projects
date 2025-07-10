// Clock constraints for RTC_Clock_Display
create_clock -name sys_clk -period 37.037 [get_ports {clk}]

# Tham chiếu đến net thay vì pin để tránh lỗi
create_generated_clock -name clk_5x_pixel -source [get_ports {clk}] -master_clock sys_clk -multiply_by 5 -divide_by 1 [get_nets {clk_5x_pixel}]
create_generated_clock -name clk_pixel -source [get_nets {clk_5x_pixel}] -master_clock clk_5x_pixel -divide_by 5 [get_nets {clk_pixel}]

# Định nghĩa các nhóm clock không đồng bộ
set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {clk_pixel clk_5x_pixel}] 