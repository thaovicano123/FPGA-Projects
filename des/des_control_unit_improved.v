module des_control_unit_improved (
    input wire clk,             // Đồng hồ hệ thống
    input wire rst_n,           // Reset tích cực mức thấp
    input wire start,           // Tín hiệu bắt đầu xử lý
    input wire key_ready,       // Tín hiệu khóa đã sẵn sàng
    input wire data_ready,      // Tín hiệu dữ liệu đầu vào đã sẵn sàng
    output reg done,            // Tín hiệu hoàn thành xử lý
    output reg error,           // Tín hiệu báo lỗi
    output reg [4:0] round_count, // Bộ đếm vòng lặp (0-16)
    
    // Tín hiệu điều khiển các khối datapath
    output reg en_ip,           // Enable Initial Permutation
    output reg en_fp,           // Enable Final Permutation
    output reg en_expansion,    // Enable Expansion
    output reg en_key_mixing,   // Enable Key Mixing (XOR)
    output reg en_sbox,         // Enable S-Box
    output reg en_pbox,         // Enable P-Box
    output reg en_feistel,      // Enable Feistel Network
    output reg en_key_schedule, // Enable Key Schedule
    
    // Tín hiệu chọn dữ liệu
    output reg sel_input,       // 1: Chọn dữ liệu đầu vào, 0: Chọn dữ liệu vòng lặp
    output reg sel_output,      // 1: Xuất dữ liệu ra ngoài, 0: Giữ dữ liệu trong vòng lặp
    
    // Tín hiệu quản lý trạng thái
    output reg [3:0] state      // Trạng thái hiện tại (chi tiết hơn)
);

    // Định nghĩa các trạng thái FSM chi tiết hơn
    localparam IDLE = 4'd0;           // Chờ lệnh start
    localparam INIT_PERM = 4'd1;      // Thực hiện Initial Permutation
    localparam KEY_SCHEDULE = 4'd2;   // Tính toán key schedule cho vòng hiện tại
    localparam EXPANSION = 4'd3;      // Thực hiện expansion
    localparam KEY_MIXING = 4'd4;     // XOR với subkey
    localparam SBOX = 4'd5;           // Thực hiện S-box
    localparam PBOX = 4'd6;           // Thực hiện P-box
    localparam FEISTEL = 4'd7;        // Hoàn thành vòng Feistel
    localparam FINAL_PERM = 4'd8;     // Thực hiện Final Permutation
    localparam DONE_STATE = 4'd9;     // Hoàn thành xử lý
    localparam ERROR_STATE = 4'd10;   // Trạng thái lỗi

    // Thanh ghi trạng thái
    reg [3:0] next_state;
    reg [4:0] next_round;

    // Quản lý trạng thái và bộ đếm vòng - Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            round_count <= 5'd0;
        end else begin
            state <= next_state;
            round_count <= next_round;
        end
    end

    // Xác định trạng thái tiếp theo và vòng tiếp theo - Combinational logic
    always @(*) begin
        // Giá trị mặc định
        next_state = state;
        next_round = round_count;
        
        case (state)
            IDLE: begin
                if (start && key_ready && data_ready) begin
                    next_state = INIT_PERM;
                    next_round = 5'd0;
                end else if (start && (!key_ready || !data_ready)) begin
                    next_state = ERROR_STATE;
                end
            end
            
            INIT_PERM: begin
                next_state = KEY_SCHEDULE;
            end
            
            KEY_SCHEDULE: begin
                next_round = round_count + 5'd1;
                next_state = EXPANSION;
            end
            
            EXPANSION: begin
                next_state = KEY_MIXING;
            end
            
            KEY_MIXING: begin
                next_state = SBOX;
            end
            
            SBOX: begin
                next_state = PBOX;
            end
            
            PBOX: begin
                next_state = FEISTEL;
            end
            
            FEISTEL: begin
                if (round_count < 16) begin
                    next_state = KEY_SCHEDULE;
                end else begin
                    next_state = FINAL_PERM;
                end
            end
            
            FINAL_PERM: begin
                next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                if (!start) begin  // Đợi start = 0 để tránh auto-restart
                    next_state = IDLE;
                end
            end
            
            ERROR_STATE: begin
                if (start && key_ready && data_ready) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Sinh tín hiệu điều khiển dựa vào trạng thái - Combinational logic
    always @(*) begin
        // Giá trị mặc định
        done = 1'b0;
        error = 1'b0;
        en_ip = 1'b0;
        en_fp = 1'b0;
        en_expansion = 1'b0;
        en_key_mixing = 1'b0;
        en_sbox = 1'b0;
        en_pbox = 1'b0;
        en_feistel = 1'b0;
        en_key_schedule = 1'b0;
        sel_input = 1'b0;
        sel_output = 1'b0;
        
        case (state)
            IDLE: begin
                sel_input = 1'b1;  // Chọn dữ liệu đầu vào
            end
            
            INIT_PERM: begin
                en_ip = 1'b1;      // Kích hoạt Initial Permutation
                sel_input = 1'b1;  // Vẫn chọn dữ liệu đầu vào
            end
            
            KEY_SCHEDULE: begin
                en_key_schedule = 1'b1;  // Tính toán khóa con cho vòng hiện tại
            end
            
            EXPANSION: begin
                en_expansion = 1'b1;     // Kích hoạt khối expansion
            end
            
            KEY_MIXING: begin
                en_key_mixing = 1'b1;    // Kích hoạt khối XOR với khóa
            end
            
            SBOX: begin
                en_sbox = 1'b1;          // Kích hoạt khối S-box
            end
            
            PBOX: begin
                en_pbox = 1'b1;          // Kích hoạt khối P-box
            end
            
            FEISTEL: begin
                en_feistel = 1'b1;       // Kích hoạt khối Feistel network
            end
            
            FINAL_PERM: begin
                en_fp = 1'b1;            // Kích hoạt Final Permutation
            end
            
            DONE_STATE: begin
                done = 1'b1;             // Báo hiệu hoàn thành
                sel_output = 1'b1;       // Chọn xuất dữ liệu
            end
            
            ERROR_STATE: begin
                error = 1'b1;            // Báo hiệu lỗi
            end
        endcase
    end

endmodule