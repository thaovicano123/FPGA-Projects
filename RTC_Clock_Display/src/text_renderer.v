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

    // Vùng viền bị tắt - không sử dụng nữa
    // localparam BORDER = SCALE;
    // wire in_border_area = (x >= TEXT_X - BORDER) && (x < TEXT_X + 8 * 8 * SCALE + BORDER) && 
    //                       (y >= TEXT_Y - BORDER) && (y < TEXT_Y + 8 * SCALE + BORDER);

    reg [3:0] chars [0:7];  // HH:MM:SS

    always @(posedge clk) begin
        chars[0] <= (hour / 10) % 10;
        chars[1] <= (hour % 10);
        chars[2] <= 4'd10; // colon
        chars[3] <= (min / 10) % 10;
        chars[4] <= (min % 10);
        chars[5] <= 4'd10;
        chars[6] <= (sec / 10) % 10;
        chars[7] <= (sec % 10);
    end

    // Tính toán vị trí tương đối trong vùng hiển thị text
    wire in_text_area = (x >= TEXT_X) && (x < TEXT_X + 8 * 8 * SCALE) && 
                        (y >= TEXT_Y) && (y < TEXT_Y + 8 * SCALE);
    
    // Tính toán vị trí trong font
    wire [9:0] rel_x = x - TEXT_X;
    wire [9:0] rel_y = y - TEXT_Y;
    wire [3:0] char_index = rel_x / (8 * SCALE);  // Tăng bit width để tránh truncation
    wire [9:0] char_x = rel_x % (8 * SCALE);
    wire [9:0] char_y = rel_y;
    
    // Tính toán vị trí pixel trong font
    wire [2:0] font_col = char_x / SCALE;
    wire [2:0] font_row = char_y / SCALE;
    
    // Kết nối font ROM inputs
    always @(*) begin
        if (in_text_area && char_index[2:0] < 8) begin
            char_code = chars[char_index[2:0]];  // Chỉ lấy 3 bit thấp
            row = font_row;  // Kết nối row signal
        end else begin
            char_code = 4'h0;  // Default character
            row = 3'h0;       // Default row
        end
    end

    // Hiệu ứng nhấp nháy bị tắt - không sử dụng nữa
    // reg [23:0] blink_counter;
    // reg blink_state;
    
    // always @(posedge clk) begin
    //     if (blink_counter == 24'd13500000) begin // Nhấp nháy mỗi 0.5 giây
    //         blink_counter <= 0;
    //         blink_state <= ~blink_state;
    //     end else begin
    //         blink_counter <= blink_counter + 1;
    //     end
    // end
    
    // Hiệu ứng màu sắc đã bị tắt - không sử dụng cho viền nữa
    // reg [7:0] color_cycle;
    // always @(posedge clk) begin
    //     if (blink_counter[19]) // Thay đổi màu chậm hơn nhấp nháy
    //         color_cycle <= color_cycle + 1;
    // end
    
    // Tạo màu sắc từ color_cycle
    // wire [7:0] color_r = (color_cycle < 8'd85) ? 8'd255 - color_cycle * 3 : 
    //                      (color_cycle < 8'd170) ? 0 : (color_cycle - 8'd170) * 3;
    // wire [7:0] color_g = (color_cycle < 8'd85) ? color_cycle * 3 : 
    //                      (color_cycle < 8'd170) ? 8'd255 - (color_cycle - 8'd85) * 3 : 0;
    // wire [7:0] color_b = (color_cycle < 8'd85) ? 0 : 
    //                      (color_cycle < 8'd170) ? (color_cycle - 8'd85) * 3 : 8'd255 - (color_cycle - 8'd170) * 3;

    // Pipeline registers để fix timing
    reg [2:0] font_col_d;
    reg [4:0] font_row_d;
    reg text_active_d;
    reg [3:0] char_index_d;
    reg [7:0] bitmap_d;
    // reg in_border_area_d;  // Không sử dụng nữa
    // reg blink_state_d;     // Không sử dụng nữa  
    // reg [7:0] color_r_d, color_g_d, color_b_d;  // Không sử dụng nữa

    always @(posedge clk) begin
        // Stage 1: Calculate position and store
        font_col_d <= font_col;
        font_row_d <= font_row;
        text_active_d <= in_text_area;
        char_index_d <= char_index[3:0];  // Store full 4-bit index
        // in_border_area_d <= in_border_area;  // Không sử dụng nữa
        // blink_state_d <= blink_state;        // Không sử dụng nữa
        // color_r_d <= color_r;                // Không sử dụng nữa
        // color_g_d <= color_g;                // Không sử dụng nữa
        // color_b_d <= color_b;                // Không sử dụng nữa

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
                // Hiển thị text với màu thay đổi theo thời gian
                if (char_index_d == 0 || char_index_d == 1) begin
                    // Giờ: màu đỏ-cam
                    //r <= 8'hFF;
                    //g <= 8'h80;
                    //b <= 8'h00;

                    r <= 8'hFF;
                    g <= 8'hFF;
                    b <= 8'hFF;
                end else if (char_index_d == 3 || char_index_d == 4) begin
                    // Phút: màu xanh lá
                    //r <= 8'h00;
                    //g <= 8'hFF;
                    //b <= 8'h80;

                    r <= 8'hFF;
                    g <= 8'hFF;
                    b <= 8'hFF;
                end else if (char_index_d == 6 || char_index_d == 7) begin
                    // Giây: màu xanh dương
                    //r <= 8'h00;
                    //g <= 8'h80;
                    //b <= 8'hFF;

                    r <= 8'hFF;
                    g <= 8'hFF;
                    b <= 8'hFF;
                end else begin
                    // Dấu hai chấm: màu trắng (không nhấp nháy)
                    r <= 8'hFF;
                    g <= 8'hFF;
                    b <= 8'hFF;
                end
            end
        end else if (x < H_ACTIVE && y < V_ACTIVE) begin
            // Nền màn hình màu đen đồng nhất
            r <= 8'h00;
            g <= 8'h00;
            b <= 8'h00;
        end
    end

endmodule
