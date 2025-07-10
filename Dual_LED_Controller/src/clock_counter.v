module clock_counter (
    input wire clk,
    input wire rst,
    input wire btn_single,      // Nút nhấn đa chức năng (sử dụng chỉ một nút này)
    input wire btn_hold,        // Không sử dụng nữa, giữ lại để tương thích
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour,
    output reg [7:0] count,     // Bộ đếm theo yêu cầu đề bài
    output wire btn_state_debounced // Trạng thái nút nhấn sau khi đã debounce
);

    // Thời gian khởi tạo - Theo yêu cầu đề bài: 13:31:43
    localparam INIT_HOUR = 5'd20;   // 13 giờ (như đề bài)
    localparam INIT_MIN = 6'd36;    // 31 phút (như đề bài)
    localparam INIT_SEC = 6'd44;    // 43 giây (như đề bài)
    localparam INIT_COUNT = 8'd0;   // Count = 0 (bắt đầu từ 0)

    reg [25:0] tick;
    
    // Đếm để đồng hồ chạy ở tốc độ thời gian thực
    // 27MHz / 27,000,000 = 1Hz (1 giây/tick)
    localparam TICK_MAX = 26'd27000000;
    
    // === XỬ LÝ NÚT NHẤN ĐA CHỨC NĂNG ===
    // Thời gian debounce cho nút nhấn
    localparam DEBOUNCE_CYCLES = 18'd135000; // 5ms ở 27MHz
    
    // Thời gian để xác định nhấn giữ
    localparam HOLD_THRESHOLD = 26'd13500000;  // 500ms ở 27MHz
    
    // Tốc độ tăng count khi giữ nút - 1 giây tăng 1
    localparam HOLD_REPEAT_RATE = 26'd27000000; // Đúng 1 giây tăng 1 lần (27MHz)
    
    // Registers cho xử lý nút nhấn
    reg [17:0] debounce_counter;
    reg [25:0] press_duration;        // Đếm thời gian nhấn giữ nút
    reg [25:0] next_increment_time;   // Thời điểm tăng count tiếp theo
    reg btn_state;                    // Trạng thái nút đã qua debounce
    reg btn_prev;                     // Trạng thái nút ở chu kỳ trước
    reg btn_pressed;                  // Nút đang được nhấn
    reg hold_mode;                    // Đã vào chế độ nhấn giữ
    
    // Xuất trạng thái nút nhấn đã qua debounce
    assign btn_state_debounced = btn_state;
    
    // Triển khai xử lý nút nhấn và đồng hồ
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset tất cả các biến
            debounce_counter <= 18'd0;
            press_duration <= 26'd0;
            next_increment_time <= 26'd0;
            btn_state <= 1'b1;          // Mặc định là HIGH (nút không nhấn)
            btn_prev <= 1'b1;
            btn_pressed <= 1'b0;
            hold_mode <= 1'b0;
            tick <= 26'd0;
            
            // Khởi tạo thời gian và count
            sec <= INIT_SEC;
            min <= INIT_MIN;
            hour <= INIT_HOUR;
            count <= INIT_COUNT;
        end else begin
            // === XỬ LÝ DEBOUNCE CHO NÚT NHẤN ===
            if (debounce_counter >= DEBOUNCE_CYCLES) begin
                btn_state <= btn_single;  // Chỉ sử dụng btn_single
                debounce_counter <= 18'd0;
            end else begin
                debounce_counter <= debounce_counter + 18'd1;
            end
            
            // === PHÁT HIỆN FALLING EDGE & RISING EDGE ===
            if (btn_prev != btn_state) begin
                if (btn_prev && !btn_state) begin
                    // FALLING EDGE (bắt đầu nhấn nút)
                    btn_pressed <= 1'b1;      // Đánh dấu nút đang được nhấn
                    press_duration <= 26'd0;   // Reset bộ đếm thời gian nhấn
                    next_increment_time <= HOLD_THRESHOLD;  // Thời điểm tăng count đầu tiên
                    hold_mode <= 1'b0;        // Reset trạng thái nhấn giữ
                end else if (!btn_prev && btn_state) begin
                    // RISING EDGE (nhả nút)
                    btn_pressed <= 1'b0;  // Đánh dấu nút đã được nhả
                    
                    // Nếu thời gian nhấn < HOLD_THRESHOLD và chưa vào chế độ hold,
                    // xử lý như nhấn nhả (single press)
                    if (press_duration < HOLD_THRESHOLD && !hold_mode) begin
                        count <= count + 8'd1;  // Tăng count
                    end
                    
                    // Reset các biến liên quan đến nhấn giữ
                    press_duration <= 26'd0;
                    next_increment_time <= 26'd0;
                    hold_mode <= 1'b0;
                end
            end
            
            // Lưu trạng thái nút ở chu kỳ trước
            btn_prev <= btn_state;
            
            // === XỬ LÝ NÚT NHẤN GIỮ VỚI KIỂM SOÁT THỜI ĐIỂM TĂNG COUNT ===
            if (btn_pressed) begin
                // Nút đang được nhấn, tăng thời gian nhấn
                press_duration <= press_duration + 26'd1;
                
                // Kiểm tra thời điểm cần tăng count
                if (press_duration == next_increment_time) begin
                    if (!hold_mode && press_duration == HOLD_THRESHOLD) begin
                        // Đạt ngưỡng nhấn giữ lần đầu
                        hold_mode <= 1'b1;
                        count <= count + 8'd1;  // Tăng count lần đầu khi vào chế độ giữ
                        next_increment_time <= press_duration + HOLD_REPEAT_RATE;  // Đặt thời điểm tăng count tiếp theo
                    end else if (hold_mode) begin
                        // Đã đến thời điểm tăng count tiếp theo trong chế độ nhấn giữ
                        count <= count + 8'd1;  // Tăng count
                        next_increment_time <= press_duration + HOLD_REPEAT_RATE;  // Đặt thời điểm tăng count tiếp theo
                    end
                end
            end
            
            // === LOGIC ĐẾM THỜI GIAN ===
            if (tick == TICK_MAX - 26'd1) begin
                tick <= 26'd0;
                if (sec == 6'd59) begin
                    sec <= 6'd0;
                    if (min == 6'd59) begin
                        min <= 6'd0;
                        if (hour == 5'd23) begin
                            hour <= 5'd0;
                        end else begin
                            hour <= hour + 5'd1;
                        end
                    end else begin
                        min <= min + 6'd1;
                    end
                end else begin
                    sec <= sec + 6'd1;
                end
            end else begin
                tick <= tick + 26'd1;
            end
        end
    end

endmodule


