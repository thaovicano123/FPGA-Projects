library verilog;
use verilog.vl_types.all;
entity rtc_top is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sec             : out    vl_logic_vector(5 downto 0);
        min             : out    vl_logic_vector(5 downto 0);
        hour            : out    vl_logic_vector(4 downto 0)
    );
end rtc_top;
