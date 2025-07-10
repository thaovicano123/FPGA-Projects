module text_renderer #(
    parameter H_ACTIVE = 640,
    parameter V_ACTIVE = 480,
    parameter SCALE = 4     // Hệ số scale cho kích thước font
)(
    input wire clk,
    input wire [9:0] x, y,
    input wire [4:0] hour,
    input wire [5:0] min,
    input wire [5:0] sec,
    input wire [4:0] day,       // Ngày (1-31)
    input wire [3:0] month,     // Tháng (1-12)
    input wire [6:0] year,      // Năm (0-99)
    input wire am_pm,           // 0 = AM, 1 = PM
    input wire mode_12h,        // 0 = 24h, 1 = 12h
    input wire [1:0] display_mode, // 0 = time, 1 = date, 2 = year
    output reg [7:0] r, g, b
);

    // Font interface
    reg [3:0] char_code;
    reg [2:0] row;
    wire [7:0] bitmap;

    (* keep = "true" *) font_rom font (
        .char_code(char_code),
        .row(row),
        .bitmap(bitmap)
    );
    
    // Debug: Ensure font ROM outputs are used
    (* keep = "true" *) wire [11:0] debug_font = {char_code, row, bitmap[7:4]};

    // Tính toán vị trí hiển thị ở giữa màn hình
    // Với SCALE=4, mỗi ký tự rộng 8*4=32 pixel, cao 8*4=32 pixel
    // Tổng cộng 8 ký tự (HH:MM:SS) nên tổng chiều rộng là 8*32=256 pixel
    localparam TEXT_X = (H_ACTIVE - 8 * 8 * SCALE) / 2;
    localparam TEXT_Y = (V_ACTIVE - 8 * SCALE) / 2;

    reg [3:0] chars [0:7];  // Array để lưu 8 ký tự hiển thị
    
    // Hiệu ứng màu sắc động
    reg [23:0] color_cycle_counter;
    reg [7:0] color_cycle;
    always @(posedge clk) begin
        color_cycle_counter <= color_cycle_counter + 1;
        if (color_cycle_counter[19]) // Thay đổi màu chậm
            color_cycle <= color_cycle + 1;
    end
    
    // Tạo màu sắc từ color_cycle
    wire [7:0] color_r = (color_cycle < 8'd85) ? 8'd255 - color_cycle * 3 : 
                         (color_cycle < 8'd170) ? 0 : (color_cycle - 8'd170) * 3;
    wire [7:0] color_g = (color_cycle < 8'd85) ? color_cycle * 3 : 
                         (color_cycle < 8'd170) ? 8'd255 - (color_cycle - 8'd85) * 3 : 0;
    wire [7:0] color_b = (color_cycle < 8'd85) ? 0 : 
                         (color_cycle < 8'd170) ? (color_cycle - 8'd85) * 3 : 8'd255 - (color_cycle - 8'd170) * 3;

    // Hiệu ứng nhấp nháy cho dấu hai chấm
    reg [23:0] blink_counter;
    reg blink_state;
    always @(posedge clk) begin
        if (blink_counter == 24'd13500000) begin // Nhấp nháy mỗi 0.5 giây
            blink_counter <= 0;
            blink_state <= ~blink_state;
        end else begin
            blink_counter <= blink_counter + 1;
        end
    end

    // Logic hiển thị theo chế độ
    wire [4:0] display_hour = mode_12h ? ((hour == 0) ? 12 : 
                                          (hour > 12) ? hour - 12 : hour) : hour;

    always @(posedge clk) begin
        case (display_mode)
            2'd0: begin // Time mode: HH:MM:SS
                chars[0] <= (display_hour / 10) % 10;
                chars[1] <= (display_hour % 10);
                chars[2] <= blink_state ? 4'd10 : 4'd13; // colon or space
                chars[3] <= (min / 10) % 10;
                chars[4] <= (min % 10);
                chars[5] <= blink_state ? 4'd10 : 4'd13;
                chars[6] <= (sec / 10) % 10;
                chars[7] <= (sec % 10);
            end
            2'd1: begin // Date mode: DD/MM/YY
                chars[0] <= (day / 10) % 10;
                chars[1] <= (day % 10);
                chars[2] <= 4'd11; // slash
                chars[3] <= (month / 10) % 10;
                chars[4] <= (month % 10);
                chars[5] <= 4'd11; // slash
                chars[6] <= (year / 10) % 10;
                chars[7] <= (year % 10);
            end
            2'd2: begin // Year mode: 20YY and AM/PM
                chars[0] <= 4'd2; // 2
                chars[1] <= 4'd0; // 0
                chars[2] <= (year / 10) % 10;
                chars[3] <= (year % 10);
                chars[4] <= 4'd13; // space
                if (mode_12h) begin
                    chars[5] <= am_pm ? 4'd13 : 4'd13; // P or A (simplified)
                    chars[6] <= 4'd13; // M
                    chars[7] <= 4'd13; // space
                end else begin
                    chars[5] <= 4'd13; // space
                    chars[6] <= 4'd13; // space
                    chars[7] <= 4'd13; // space
                end
            end
            default: begin // Default to time
                chars[0] <= (display_hour / 10) % 10;
                chars[1] <= (display_hour % 10);
                chars[2] <= 4'd10; // colon
                chars[3] <= (min / 10) % 10;
                chars[4] <= (min % 10);
                chars[5] <= 4'd10;
                chars[6] <= (sec / 10) % 10;
                chars[7] <= (sec % 10);
            end
        endcase
    end

    // Tính toán vị trí tương đối trong vùng hiển thị text
    wire in_text_area = (x >= TEXT_X) && (x < TEXT_X + 8 * 8 * SCALE) && 
                        (y >= TEXT_Y) && (y < TEXT_Y + 8 * SCALE);
    
    // Tính toán vị trí trong font
    wire [9:0] rel_x = x - TEXT_X;
    wire [9:0] rel_y = y - TEXT_Y;
    wire [3:0] char_index = rel_x / (8 * SCALE);
    wire [9:0] char_x = rel_x % (8 * SCALE);
    wire [9:0] char_y = rel_y;
    
    // Tính toán vị trí pixel trong font
    wire [2:0] font_col = char_x / SCALE;
    wire [2:0] font_row = char_y / SCALE;
    
    // Kết nối font ROM inputs
    always @(*) begin
        if (in_text_area && char_index[2:0] < 8) begin
            char_code = chars[char_index[2:0]];
            row = font_row;
        end else begin
            char_code = 4'h0;
            row = 3'h0;
        end
    end

    // Pipeline registers để fix timing
    reg [2:0] font_col_d;
    reg [2:0] font_row_d;
    reg text_active_d;
    reg [3:0] char_index_d;
    reg [7:0] bitmap_d;
    reg [1:0] display_mode_d;
    reg [7:0] color_r_d, color_g_d, color_b_d;

    always @(posedge clk) begin
        // Stage 1: Calculate position and store
        font_col_d <= font_col;
        font_row_d <= font_row;
        text_active_d <= in_text_area;
        char_index_d <= char_index[3:0];
        display_mode_d <= display_mode;
        color_r_d <= color_r;
        color_g_d <= color_g;
        color_b_d <= color_b;

        // Stage 2: Capture font ROM output
        bitmap_d <= bitmap;
    end

    // Stage 3: Generate final color output
    always @(posedge clk) begin
        // Mặc định: nền đen
        r <= 8'h00;
        g <= 8'h00;
        b <= 8'h00;

        if (text_active_d) begin
            if (bitmap_d[7 - font_col_d]) begin
                case (display_mode_d)
                    2'd0: begin // Time mode - màu sắc động
                        if (char_index_d == 0 || char_index_d == 1) begin
                            // Giờ: màu đỏ-cam
                            r <= color_r_d;
                            g <= 8'h80;
                            b <= 8'h00;
                        end else if (char_index_d == 3 || char_index_d == 4) begin
                            // Phút: màu xanh lá
                            r <= 8'h00;
                            g <= color_g_d;
                            b <= 8'h80;
                        end else if (char_index_d == 6 || char_index_d == 7) begin
                            // Giây: màu xanh dương
                            r <= 8'h00;
                            g <= 8'h80;
                            b <= color_b_d;
                        end else begin
                            // Dấu hai chấm: màu trắng
                            r <= 8'hFF;
                            g <= 8'hFF;
                            b <= 8'hFF;
                        end
                    end
                    2'd1: begin // Date mode - màu cam
                        r <= 8'hFF;
                        g <= 8'hA5;
                        b <= 8'h00;
                    end
                    2'd2: begin // Year mode - màu tím
                        r <= 8'h80;
                        g <= 8'h00;
                        b <= 8'hFF;
                    end
                    default: begin // Màu trắng
                        r <= 8'hFF;
                        g <= 8'hFF;
                        b <= 8'hFF;
                    end
                endcase
            end
        end else if (x < H_ACTIVE && y < V_ACTIVE) begin
            // Nền màn hình màu đen đồng nhất
            r <= 8'h00;
            g <= 8'h00;
            b <= 8'h00;
        end
    end

endmodule
