module top(
    input clk,           // SYS_CLK  (Pin 45)
    input resetn,        // Reset button (Pin 14)

    output tmds_clk_p,
    output tmds_clk_n,
    output [2:0] tmds_d_p,
    output [2:0] tmds_d_n
);

// === PLL & Clock Divider ===
wire clk_pixel, clk_5x_pixel, pll_lock, sys_resetn;

// PLL tạo clock 5x pixel (khoảng 135MHz cho 27MHz pixel clock)
Gowin_PLLVR pll_inst(
    .clkout(clk_5x_pixel),
    .lock(pll_lock),
    .clkin(clk)
);

// Clock divider chia 5 để tạo pixel clock (khoảng 27MHz cho VGA 640x480@60Hz)
Gowin_CLKDIV div_inst(
    .clkout(clk_pixel),
    .hclkin(clk_5x_pixel),
    .resetn(pll_lock)
);

// === Reset đồng bộ ===
Reset_Sync reset_sync(
    .resetn(sys_resetn),
    .ext_reset(resetn & pll_lock),
    .clk(clk_pixel)
);

// === Bộ đếm thời gian thực ===
wire [4:0] hour;
wire [5:0] min, sec;
(* keep = "true" *) clock_counter u_clk (
    .clk(clk_pixel),
    .rst(~sys_resetn),
    .sec(sec),
    .min(min),
    .hour(hour)
);

// === Tạo timing VGA/HDMI ===
wire [9:0] x, y;
wire hsync, vsync, de;
video_timing timing_gen (
    .clk(clk_pixel),
    .resetn(sys_resetn),
    .x(x),
    .y(y),
    .hsync(hsync),
    .vsync(vsync),
    .de(de)
);

// === Hiển thị số giờ:phút:giây ra màn hình ===
wire [7:0] r, g, b;
(* keep = "true" *) text_renderer #(
    .H_ACTIVE(640),
    .V_ACTIVE(480),
    .SCALE(4)    // Tăng kích thước font lên 4 lần
) u_text (
    .clk(clk_pixel),
    .x(x),
    .y(y),
    .hour(hour),
    .min(min),
    .sec(sec),
    .r(r),
    .g(g),
    .b(b)
);

// Debug: Đảm bảo time signals được sử dụng
(* keep = "true" *) wire [15:0] debug_time = {hour[4:0], min[5:0], sec[4:0]};

// === HDMI Encoder đơn giản ===
wire [9:0] tmds_red, tmds_green, tmds_blue;

// TMDS encoding cho kênh đỏ (Red) - có sync control
svo_tmds enc_red (
    .clk(clk_pixel),
    .resetn(sys_resetn),
    .de(de),
    .ctrl({vsync, hsync}),  // Control signals chỉ cho kênh đỏ
    .din(r),
    .dout(tmds_red)
);

// TMDS encoding cho kênh xanh lá (Green)
svo_tmds enc_green (
    .clk(clk_pixel),
    .resetn(sys_resetn),
    .de(de),
    .ctrl(2'b00),          // Không có control signals
    .din(g),
    .dout(tmds_green)
);

// TMDS encoding cho kênh xanh dương (Blue)
svo_tmds enc_blue (
    .clk(clk_pixel),
    .resetn(sys_resetn),
    .de(de),
    .ctrl(2'b00),          // Không có control signals
    .din(b),
    .dout(tmds_blue)
);

// === Serializer 10:1 cho TMDS ===
wire [2:0] tmds_data_serial;

OSER10 tmds_serdes_red (
    .Q(tmds_data_serial[0]),
    .D0(tmds_red[0]),
    .D1(tmds_red[1]),
    .D2(tmds_red[2]),
    .D3(tmds_red[3]),
    .D4(tmds_red[4]),
    .D5(tmds_red[5]),
    .D6(tmds_red[6]),
    .D7(tmds_red[7]),
    .D8(tmds_red[8]),
    .D9(tmds_red[9]),
    .PCLK(clk_pixel),
    .FCLK(clk_5x_pixel),
    .RESET(~sys_resetn)
);

OSER10 tmds_serdes_green (
    .Q(tmds_data_serial[1]),
    .D0(tmds_green[0]),
    .D1(tmds_green[1]),
    .D2(tmds_green[2]),
    .D3(tmds_green[3]),
    .D4(tmds_green[4]),
    .D5(tmds_green[5]),
    .D6(tmds_green[6]),
    .D7(tmds_green[7]),
    .D8(tmds_green[8]),
    .D9(tmds_green[9]),
    .PCLK(clk_pixel),
    .FCLK(clk_5x_pixel),
    .RESET(~sys_resetn)
);

OSER10 tmds_serdes_blue (
    .Q(tmds_data_serial[2]),
    .D0(tmds_blue[0]),
    .D1(tmds_blue[1]),
    .D2(tmds_blue[2]),
    .D3(tmds_blue[3]),
    .D4(tmds_blue[4]),
    .D5(tmds_blue[5]),
    .D6(tmds_blue[6]),
    .D7(tmds_blue[7]),
    .D8(tmds_blue[8]),
    .D9(tmds_blue[9]),
    .PCLK(clk_pixel),
    .FCLK(clk_5x_pixel),
    .RESET(~sys_resetn)
);

// === Differential output buffers ===
ELVDS_OBUF tmds_buffers [3:0] (
    .I({clk_pixel, tmds_data_serial}),
    .O({tmds_clk_p, tmds_d_p}),
    .OB({tmds_clk_n, tmds_d_n})
);

endmodule 