module des_control_unit (
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
    output reg [1:0] state      // Trạng thái hiện tại (00: IDLE, 01: RUN, 10: DONE, 11: ERROR)
);

    // Định nghĩa các trạng thái
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;
    localparam ERROR = 2'b11;

    // Thanh ghi trạng thái
    reg [1:0] next_state;

    // Quản lý trạng thái - Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            round_count <= 5'd0;
        end else begin
            state <= next_state;
            
            // Quản lý bộ đếm vòng lặp
            if (state == IDLE) begin
                round_count <= 5'd0;
            end else if (state == RUN) begin
                if (round_count < 16)
                    round_count <= round_count + 1'b1;
            end
        end
    end

    // Xác định trạng thái tiếp theo - Combinational logic
    always @(*) begin
        // Giá trị mặc định
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start && key_ready && data_ready)
                    next_state = RUN;
                else if (start && (!key_ready || !data_ready))
                    next_state = ERROR;
            end
            
            RUN: begin
                if (round_count == 16)
                    next_state = DONE;
            end
            
            DONE: begin
                next_state = IDLE; // Quay về trạng thái IDLE sau khi xử lý xong
            end
            
            ERROR: begin
                if (start && key_ready && data_ready)
                    next_state = IDLE; // Quay về IDLE khi các điều kiện đã sẵn sàng
            end
            
            default: next_state = IDLE;
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
                en_ip = start && key_ready && data_ready; // Kích hoạt IP khi bắt đầu
                en_key_schedule = start && key_ready; // Kích hoạt key schedule khi bắt đầu
            end
            
            RUN: begin
                // Kích hoạt các khối datapath trong vòng lặp
                en_expansion = 1'b1;
                en_key_mixing = 1'b1;
                en_sbox = 1'b1;
                en_pbox = 1'b1;
                en_feistel = 1'b1;
                en_key_schedule = 1'b1; // Sinh khóa con cho vòng hiện tại
                
                // Vòng cuối cùng (16) thì chuẩn bị hoàn thành
                if (round_count == 16)
                    en_fp = 1'b1; // Kích hoạt Final Permutation
            end
            
            DONE: begin
                done = 1'b1;
                sel_output = 1'b1; // Cho phép xuất dữ liệu ra ngoài
            end
            
            ERROR: begin
                error = 1'b1;
            end
        endcase
    end

endmodule