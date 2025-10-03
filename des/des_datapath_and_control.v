module des_datapath_and_control (
    input wire clk,             // Đồng hồ hệ thống
    input wire rst_n,           // Reset tích cực mức thấp
    input wire start,           // Tín hiệu bắt đầu xử lý
    input wire encrypt,         // 1: Mã hóa, 0: Giải mã
    input wire [63:0] data_in,  // Dữ liệu đầu vào 64-bit
    input wire [63:0] key,      // Khóa 64-bit
    output wire [63:0] data_out, // Dữ liệu đầu ra 64-bit
    output wire done,           // Tín hiệu hoàn thành
    output wire error           // Tín hiệu lỗi
);

    // Tín hiệu nội bộ
    wire key_ready, data_ready;
    wire [4:0] round_count;
    wire [47:0] subkey;         // Khóa con 48-bit cho mỗi vòng
    wire [31:0] left, right;    // Nửa trái và phải của dữ liệu
    wire [31:0] left_next, right_next; // Nửa trái và phải sau mỗi vòng
    wire [31:0] feistel_out;    // Đầu ra của hàm Feistel
    wire [31:0] expansion_out;  // Đầu ra của mở rộng (48-bit)
    wire [47:0] key_mix_out;    // Đầu ra của phép XOR với khóa
    wire [31:0] sbox_out;       // Đầu ra của S-box
    wire [31:0] pbox_out;       // Đầu ra của P-box
    
    // Tín hiệu điều khiển từ Control Unit
    wire en_ip, en_fp, en_expansion, en_key_mixing;
    wire en_sbox, en_pbox, en_feistel, en_key_schedule;
    wire sel_input, sel_output;
    wire [3:0] state;           // Trạng thái FSM hiện tại

    // Thanh ghi để lưu dữ liệu đầu vào và đầu ra
    reg [63:0] data_reg_in;     // Dữ liệu đầu vào đã qua IP
    reg [63:0] data_reg_out;    // Dữ liệu đầu ra cuối cùng
    reg [63:0] key_reg;         // Khóa đã lưu
    
    // Đặt tín hiệu ready khi dữ liệu và khóa đã được cung cấp
    assign key_ready = 1'b1;    // Trong ví dụ này, luôn sẵn sàng
    assign data_ready = 1'b1;   // Trong ví dụ này, luôn sẵn sàng
    
    // Tách dữ liệu thành nửa trái và phải
    assign left = data_reg_in[63:32];
    assign right = data_reg_in[31:0];
    
    // Đầu ra cuối cùng
    assign data_out = data_reg_out;

    // Khởi tạo Control Unit
    des_control_unit_improved control_unit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .key_ready(key_ready),
        .data_ready(data_ready),
        .done(done),
        .error(error),
        .round_count(round_count),
        .en_ip(en_ip),
        .en_fp(en_fp),
        .en_expansion(en_expansion),
        .en_key_mixing(en_key_mixing),
        .en_sbox(en_sbox),
        .en_pbox(en_pbox),
        .en_feistel(en_feistel),
        .en_key_schedule(en_key_schedule),
        .sel_input(sel_input),
        .sel_output(sel_output),
        .state(state)
    );

    // Khối Key Schedule để tạo các khóa con
    // (Đây là một phiên bản đơn giản, trong thực tế cần thiết kế đầy đủ)
    always @(posedge clk) begin
        if (!rst_n) begin
            key_reg <= 64'd0;
        end else if (sel_input) begin
            key_reg <= key;
        end
    end

    // Mô phỏng Key Schedule - trong thực tế cần thiết kế đầy đủ
    assign subkey = key_reg[round_count +: 48]; // Chỉ để minh họa, không phải thuật toán thực

    // Khối Initial Permutation (IP)
    always @(posedge clk) begin
        if (!rst_n) begin
            data_reg_in <= 64'd0;
        end else if (en_ip) begin
            // Thực hiện IP - trong thực tế cần thiết kế đầy đủ
            data_reg_in <= data_in; // Đơn giản hóa, không thực hiện hoán vị thực sự
        end
    end

    // Mô phỏng Expansion - trong thực tế cần thiết kế đầy đủ
    assign expansion_out = right; // Đơn giản hóa, không thực hiện mở rộng thực sự

    // Mô phỏng Key Mixing - trong thực tế cần thiết kế đầy đủ
    assign key_mix_out = expansion_out ^ subkey[31:0]; // Đơn giản hóa, XOR với 32 bit thấp của subkey

    // Mô phỏng S-box - trong thực tế cần thiết kế đầy đủ
    assign sbox_out = key_mix_out; // Đơn giản hóa, không thực hiện S-box thực sự

    // Mô phỏng P-box - trong thực tế cần thiết kế đầy đủ
    assign pbox_out = sbox_out; // Đơn giản hóa, không thực hiện P-box thực sự

    // Mô phỏng Feistel function
    assign feistel_out = pbox_out;

    // Cập nhật nửa trái và phải sau mỗi vòng Feistel
    assign left_next = right;
    assign right_next = left ^ feistel_out;

    // Cập nhật dữ liệu sau mỗi vòng
    always @(posedge clk) begin
        if (!rst_n) begin
            data_reg_in <= 64'd0;
        end else if (en_feistel) begin
            data_reg_in <= {left_next, right_next}; // Cập nhật cho vòng tiếp theo
        end
    end

    // Final Permutation và output
    always @(posedge clk) begin
        if (!rst_n) begin
            data_reg_out <= 64'd0;
        end else if (en_fp) begin
            // Thực hiện FP - trong thực tế cần thiết kế đầy đủ
            // Hoán vị cuối cùng và ghép lại
            data_reg_out <= {right_next, left_next}; // Đơn giản hóa, hoán đổi L/R
        end
    end

endmodule