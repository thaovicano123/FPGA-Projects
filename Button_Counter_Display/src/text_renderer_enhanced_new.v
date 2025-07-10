module text_renderer_enhanced #(
    parameter H_ACTIVE = 640,
    parameter V_ACTIVE = 480,
    parameter SCALE = 4     // Hệ số scale cho kích thước font
)(
    input wire clk,
    input wire [9:0] x, y,
    input wire [4:0] hour,
    input wire [5:0] min,
    input wire [5:0] sec,
    input wire [4:0] day,       // Ngày
    input wire [3:0] month,     // Tháng  
    input wire [6:0] year,      // Năm
    input wire am_pm,           // AM/PM flag
    input wire mode_12h,        // 12h mode flag
    input wire [1:0] display_mode, // 0=time, 1=date, 2=year
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
    // Tổng cộng 8 ký tự nên tổng chiều rộng là 8*32=256 pixel
    localparam TEXT_X = (H_ACTIVE - 8 * 8 * SCALE) / 2;
    localparam TEXT_Y = (V_ACTIVE - 8 * SCALE) / 2;

    reg [3:0] chars [0:7];  // 8 ký tự để hiển thị

    // Chuyển đổi giờ cho chế độ 12h
    reg [4:0] display_hour;
    always @(*) begin
        if (mode_12h) begin
            if (hour == 0)
                display_hour = 12;  // 00:xx = 12:xx AM
            else if (hour <= 12)
                display_hour = hour;
            else
                display_hour = hour - 12;  // 13:xx = 1:xx PM
        end else begin
            display_hour = hour;
        end
    end

    // Chuẩn bị dữ liệu hiển thị theo mode
    always @(posedge clk) begin
        case (display_mode)
            2'd0: begin // Time mode: HH:MM:SS hoặc HH:MM:SS AM/PM
                chars[0] <= (display_hour / 10) % 10;
                chars[1] <= (display_hour % 10);
                chars[2] <= 4'd10; // colon ":"
                chars[3] <= (min / 10) % 10;
                chars[4] <= (min % 10);
                chars[5] <= 4'd10; // colon ":"
                chars[6] <= (sec / 10) % 10;
                chars[7] <= (sec % 10);
            end
            2'd1: begin // Date mode: DD/MM
                chars[0] <= (day / 10) % 10;
                chars[1] <= (day % 10);
                chars[2] <= 4'd11; // slash "/"
                chars[3] <= (month / 10) % 10;
                chars[4] <= (month % 10);
                chars[5] <= 4'd13; // space
                chars[6] <= 4'd13; // space
                chars[7] <= 4'd13; // space
            end
            2'd2: begin // Year mode: 20YY
                chars[0] <= 4'd2;  // "2"
                chars[1] <= 4'd0;  // "0"
                chars[2] <= (year / 10) % 10;
                chars[3] <= (year % 10);
                chars[4] <= 4'd13; // space
                chars[5] <= 4'd13; // space
                chars[6] <= 4'd13; // space
                chars[7] <= 4'd13; // space
            end
            default: begin // Default to time
                chars[0] <= (display_hour / 10) % 10;
                chars[1] <= (display_hour % 10);
                chars[2] <= 4'd10; // colon ":"
                chars[3] <= (min / 10) % 10;
                chars[4] <= (min % 10);
                chars[5] <= 4'd10; // colon ":"
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
    reg text_active_d;
    reg [3:0] char_index_d;
    reg [7:0] bitmap_d;
    reg [1:0] display_mode_d;
    reg am_pm_d, mode_12h_d;

    always @(posedge clk) begin
        // Stage 1: Calculate position and store
        font_col_d <= font_col;
        text_active_d <= in_text_area;
        char_index_d <= char_index[3:0];
        display_mode_d <= display_mode;
        am_pm_d <= am_pm;
        mode_12h_d <= mode_12h;

        // Stage 2: Capture font ROM output
        bitmap_d <= bitmap;
    end

    // Color counter for dynamic effects
    reg [7:0] color_counter;
    always @(posedge clk) begin
        color_counter <= color_counter + 1;
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
                    2'd0: begin // Time mode
                        if (mode_12h_d) begin
                            // Chế độ 12h: màu vàng + hiệu ứng AM/PM
                            if (am_pm_d) begin // PM - màu cam
                                r <= 8'hFF;
                                g <= 8'hA5;
                                b <= 8'h00;
                            end else begin // AM - màu vàng
                                r <= 8'hFF;
                                g <= 8'hFF;
                                b <= 8'h00;
                            end
                        end else begin
                            // Chế độ 24h: màu trắng với hiệu ứng nhấp nháy giây
                            if ((char_index_d == 6 || char_index_d == 7) && color_counter[6]) begin
                                // Giây nhấp nháy
                                r <= 8'h80;
                                g <= 8'hFF;
                                b <= 8'h80;
                            end else begin
                                // Giờ phút bình thường
                                r <= 8'hFF;
                                g <= 8'hFF;
                                b <= 8'hFF;
                            end
                        end
                    end
                    2'd1: begin // Date mode - màu xanh dương
                        r <= 8'h00;
                        g <= 8'hBF + {1'b0, color_counter[6:0]};  // Hiệu ứng breathing
                        b <= 8'hFF;
                    end
                    2'd2: begin // Year mode - màu xanh lá với hiệu ứng gradient
                        r <= 8'h00;
                        g <= 8'hFF;
                        b <= 8'h00 + {1'b0, color_counter[6:0]};  // Hiệu ứng gradient
                    end
                    default: begin // Default - trắng
                        r <= 8'hFF;
                        g <= 8'hFF;
                        b <= 8'hFF;
                    end
                endcase
            end
        end else if (x < H_ACTIVE && y < V_ACTIVE) begin
            // Nền màn hình
            r <= 8'h00;
            g <= 8'h00;
            b <= 8'h00;
        end
    end

    // AM/PM indicator - hiển thị ở góc dưới phải khi ở chế độ 12h
    wire in_ampm_area = mode_12h_d && (display_mode_d == 0) && 
                       (x >= TEXT_X + 6*8*SCALE) && (x < TEXT_X + 8*8*SCALE) &&
                       (y >= TEXT_Y + 6*SCALE) && (y < TEXT_Y + 8*SCALE);
    
    // Override color for AM/PM indicator
    always @(posedge clk) begin
        if (in_ampm_area && mode_12h_d && (display_mode_d == 0)) begin
            // Tạo text "AM" hoặc "PM" nhỏ
            if (am_pm_d) begin // PM
                r <= 8'hFF; g <= 8'h40; b <= 8'h40; // Đỏ
            end else begin // AM  
                r <= 8'h40; g <= 8'h40; b <= 8'hFF; // Xanh
            end
        end
    end

endmodule
