library verilog;
use verilog.vl_types.all;
entity clk_divider is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        clk_1hz         : out    vl_logic
    );
end clk_divider;
