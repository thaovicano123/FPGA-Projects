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
    input wire [7:0] count,     // Bộ đếm theo yêu cầu bài tập 2
    output reg [7:0] r, g, b
);

    // Font interface
    reg [4:0] char_code;  // Mở rộng thành 5-bit để hỗ trợ đến 32 ký tự
    reg [2:0] row;
    wire [7:0] bitmap;

    (* keep = "true" *) font_rom font (
        .char_code(char_code),
        .row(row),
        .bitmap(bitmap)
    );

    // Tính toán vị trí hiển thị chính xác theo yêu cầu đề bài  
    // Dòng 1: HH:MM:SS (8 ký tự) - Màu trắng
    // Dòng 2: Count = XX (10 ký tự) - Màu trắng
    localparam TEXT_X1 = (H_ACTIVE - 8 * 8 * SCALE) / 2;   // Căn giữa cho thời gian
    localparam TEXT_X2 = (H_ACTIVE - 10 * 8 * SCALE) / 2;  // Căn giữa cho count (10 ký tự: "Count = XX")
    localparam TEXT_Y1 = V_ACTIVE / 3;                     // Dòng thời gian - khoảng 1/3 màn hình
    localparam TEXT_Y2 = (V_ACTIVE * 2) / 3;               // Dòng count - khoảng 2/3 màn hình

    reg [4:0] chars_time [0:7];    // 8 ký tự cho thời gian HH:MM:SS
    reg [4:0] chars_count [0:9];   // 10 ký tự cho "Count = XX" (2 chữ số count)

    // Chuẩn bị dữ liệu hiển thị thời gian
  always @(posedge clk) begin
    // Dòng 1: Hiển thị thời gian HH:MM:SS
    chars_time[0] <= (hour / 10) % 10;
    chars_time[1] <= (hour % 10);
    chars_time[2] <= 5'd10; // colon ":"
    chars_time[3] <= (min / 10) % 10;
    chars_time[4] <= (min % 10);
    chars_time[5] <= 5'd10; // colon ":"
    chars_time[6] <= (sec / 10) % 10;
    chars_time[7] <= (sec % 10);        // Dòng 2: "Count = XX" theo yêu cầu
    chars_count[0] <= 5'd14;  // "C"
    chars_count[1] <= 5'd15;  // "o"
    chars_count[2] <= 5'd16;  // "u"
    chars_count[3] <= 5'd17;  // "n"
    chars_count[4] <= 5'd18;  // "t"
    chars_count[5] <= 5'd13;  // space (khoảng trắng)
    chars_count[6] <= 5'd19;  // "="
    chars_count[7] <= 5'd13;  // space (khoảng trắng)
    chars_count[8] <= (count / 10) % 10;  // Chữ số hàng chục của count
    chars_count[9] <= count % 10;         // Chữ số hàng đơn vị của count
end



    // Tính toán vị trí tương đối trong vùng hiển thị text
    wire in_text_area1 = (x >= TEXT_X1) && (x < TEXT_X1 + 8 * 8 * SCALE) && 
                         (y >= TEXT_Y1) && (y < TEXT_Y1 + 8 * SCALE);
    wire in_text_area2 = (x >= TEXT_X2) && (x < TEXT_X2 + 10 * 8 * SCALE) && 
                         (y >= TEXT_Y2) && (y < TEXT_Y2 + 8 * SCALE);

    // Tính toán vị trí pixel cho dòng 1
    wire [4:0] char_index1 = (x - TEXT_X1) / (8 * SCALE);  // Mở rộng thành 5-bit
    wire [2:0] font_col1 = ((x - TEXT_X1) % (8 * SCALE)) / SCALE;
    wire [2:0] font_row1 = ((y - TEXT_Y1) % (8 * SCALE)) / SCALE;

    // Tính toán vị trí pixel cho dòng 2  
    wire [4:0] char_index2 = (x - TEXT_X2) / (8 * SCALE);  // Mở rộng thành 5-bit
    wire [2:0] font_col2 = ((x - TEXT_X2) % (8 * SCALE)) / SCALE;
    wire [2:0] font_row2 = ((y - TEXT_Y2) % (8 * SCALE)) / SCALE;

    // Pipeline registers
    reg [2:0] font_col_d;
    reg text_active1_d, text_active2_d;
    reg [4:0] char_index_d;  // Mở rộng thành 5-bit để khớp với char_index1/2
    reg [7:0] bitmap_d;

    always @(posedge clk) begin
        // Stage 1: Prepare for font ROM access
        if (in_text_area1 && char_index1 < 8) begin
            char_code <= chars_time[char_index1];
            row <= font_row1;
            font_col_d <= font_col1;
            text_active1_d <= 1'b1;
            text_active2_d <= 1'b0;
            char_index_d <= char_index1;
        end else if (in_text_area2 && char_index2 < 10) begin
            char_code <= chars_count[char_index2];
            row <= font_row2;
            font_col_d <= font_col2;
            text_active1_d <= 1'b0;
            text_active2_d <= 1'b1;
            char_index_d <= char_index2;
        end else begin
            char_code <= 4'd0;
            row <= 3'd0;
            font_col_d <= 3'd0;
            text_active1_d <= 1'b0;
            text_active2_d <= 1'b0;
            char_index_d <= 4'd0;
        end

        // Stage 2: Capture font ROM output
        bitmap_d <= bitmap;
    end

    // Color counter for dynamic effects
    reg [7:0] color_counter;
    always @(posedge clk) begin
        color_counter <= color_counter + 8'd1;
    end

    // Stage 3: Generate final color output
    always @(posedge clk) begin
        // Mặc định: nền đen
        r <= 8'h00;
        g <= 8'h00;
        b <= 8'h00;

        if ((text_active1_d || text_active2_d) && bitmap_d[7 - font_col_d]) begin
            // Cả hai dòng đều hiển thị màu trắng
            r <= 8'hFF;  // Red: 255
            g <= 8'hFF;  // Green: 255
            b <= 8'hFF;  // Blue: 255
        end
    end

endmodule
