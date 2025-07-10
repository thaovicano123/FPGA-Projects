module top(
    input clk,           // SYS_CLK  (Pin 45)
    input resetn,        // Reset button (Pin 14)
    input btn_single,    // Nút nhấn đa chức năng (Pin 15) - Hỗ trợ cả nhấn nhả và nhấn giữ
    input btn_hold,      // Không sử dụng, giữ lại để tương thích (Pin 16)

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

// === Bộ đếm thời gian và counter theo yêu cầu bài tập 2 ===
wire [4:0] hour;
wire [5:0] min, sec;
wire [7:0] count;    // Bộ đếm theo yêu cầu đề bài

(* keep = "true" *) clock_counter u_clk (
    .clk(clk_pixel),
    .rst(~sys_resetn),
    .btn_single(btn_single),    // Nút nhấn đa chức năng
    .btn_hold(1'b1),            // Không sử dụng, set mặc định HIGH (inactive)
    .sec(sec),
    .min(min),
    .hour(hour),
    .count(count)
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

// === Hiển thị thời gian và count ra màn hình ===
wire [7:0] r, g, b;
(* keep = "true" *) text_renderer_enhanced #(
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
    .count(count),
    .r(r),
    .g(g),
    .b(b)
);

// Debug: Đảm bảo time signals được sử dụng
(* keep = "true" *) wire [31:0] debug_time = {16'h0000, hour[4:0], min[5:0], sec[4:0], count[7:0]};

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
ELVDS_OBUF tmds_clk_buffer (
    .I(clk_pixel),
    .O(tmds_clk_p),
    .OB(tmds_clk_n)
);

ELVDS_OBUF tmds_data_buffer_0 (
    .I(tmds_data_serial[0]),
    .O(tmds_d_p[0]),
    .OB(tmds_d_n[0])
);

ELVDS_OBUF tmds_data_buffer_1 (
    .I(tmds_data_serial[1]),
    .O(tmds_d_p[1]),
    .OB(tmds_d_n[1])
);

ELVDS_OBUF tmds_data_buffer_2 (
    .I(tmds_data_serial[2]),
    .O(tmds_d_p[2]),
    .OB(tmds_d_n[2])
);

endmodule