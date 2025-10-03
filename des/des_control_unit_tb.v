`timescale 1ns/1ps

module des_control_unit_tb();

    // Định nghĩa các tín hiệu
    reg clk;
    reg rst_n;
    reg start;
    reg key_ready;
    reg data_ready;
    
    wire done;
    wire error;
    wire [4:0] round_count;
    wire en_ip, en_fp, en_expansion, en_key_mixing;
    wire en_sbox, en_pbox, en_feistel, en_key_schedule;
    wire sel_input, sel_output;
    wire [1:0] state;
    
    // Định nghĩa các trạng thái để theo dõi dễ dàng
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;
    localparam ERROR = 2'b11;
    
    // Instantiate DES Control Unit
    des_control_unit dut (
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
    
    // Tạo tín hiệu đồng hồ 10ns (100MHz)
    always #5 clk = ~clk;
    
    // Khai báo task để kiểm tra và hiển thị trạng thái
    task check_state;
        input [1:0] expected_state;
        input string state_name;
        begin
            if (state == expected_state)
                $display("PASS: State is %s as expected", state_name);
            else
                $display("FAIL: State should be %s but is %b", state_name, state);
        end
    endtask
    
    // Khai báo task để kiểm tra các tín hiệu điều khiển
    task check_control_signals;
        input exp_en_ip, exp_en_fp, exp_en_expansion, exp_en_key_mixing;
        input exp_en_sbox, exp_en_pbox, exp_en_feistel, exp_en_key_schedule;
        input exp_sel_input, exp_sel_output;
        begin
            if (en_ip == exp_en_ip && en_fp == exp_en_fp && 
                en_expansion == exp_en_expansion && en_key_mixing == exp_en_key_mixing &&
                en_sbox == exp_en_sbox && en_pbox == exp_en_pbox &&
                en_feistel == exp_en_feistel && en_key_schedule == exp_en_key_schedule &&
                sel_input == exp_sel_input && sel_output == exp_sel_output)
                $display("PASS: Control signals are correct for current state");
            else
                $display("FAIL: Control signals are not as expected");
        end
    endtask
    
    // Khai báo các biến hỗ trợ cho test
    integer i;
    
    // Khối initial chứa các test case
    initial begin
        // Khởi tạo giá trị cho các tín hiệu
        clk = 0;
        rst_n = 0;
        start = 0;
        key_ready = 0;
        data_ready = 0;
        
        // Kích hoạt reset
        #20 rst_n = 1;
        
        // Kiểm tra trạng thái IDLE sau reset
        #10;
        check_state(IDLE, "IDLE");
        
        // Test case 1: Chuyển từ IDLE sang RUN khi start=1 và key/data ready
        $display("\n--- Test Case 1: IDLE to RUN ---");
        key_ready = 1;
        data_ready = 1;
        start = 1;
        #10;
        start = 0; // Bỏ tín hiệu start sau 1 chu kỳ
        check_state(RUN, "RUN");
        check_control_signals(0, 0, 1, 1, 1, 1, 1, 1, 0, 0);
        
        // Test case 2: Theo dõi bộ đếm vòng lặp trong RUN
        $display("\n--- Test Case 2: Round Counter in RUN state ---");
        for (i = 1; i <= 16; i = i + 1) begin
            #10; // Đợi 1 chu kỳ đồng hồ
            $display("Round counter: %0d", round_count);
            if (round_count == i)
                $display("PASS: Round counter is correct");
            else
                $display("FAIL: Round counter should be %0d but is %0d", i, round_count);
                
            // Kiểm tra tín hiệu en_fp trong vòng cuối cùng
            if (i == 16) begin
                if (en_fp == 1)
                    $display("PASS: Final Permutation enabled in last round");
                else
                    $display("FAIL: Final Permutation should be enabled in last round");
            end
        end
        
        // Test case 3: Chuyển từ RUN sang DONE sau 16 vòng
        $display("\n--- Test Case 3: RUN to DONE ---");
        #10; // Đợi thêm 1 chu kỳ sau vòng 16
        check_state(DONE, "DONE");
        if (done == 1 && sel_output == 1)
            $display("PASS: done and sel_output signals are active in DONE state");
        else
            $display("FAIL: done and sel_output signals should be active in DONE state");
            
        // Test case 4: Chuyển từ DONE về IDLE
        $display("\n--- Test Case 4: DONE to IDLE ---");
        #10;
        check_state(IDLE, "IDLE");
        
        // Test case 5: Kiểm tra trạng thái ERROR
        $display("\n--- Test Case 5: ERROR state ---");
        key_ready = 0; // Key chưa sẵn sàng
        data_ready = 1;
        start = 1;
        #10;
        start = 0;
        check_state(ERROR, "ERROR");
        if (error == 1)
            $display("PASS: error signal is active in ERROR state");
        else
            $display("FAIL: error signal should be active in ERROR state");
        
        // Test case 6: Khôi phục từ ERROR
        $display("\n--- Test Case 6: Recovery from ERROR ---");
        key_ready = 1;
        data_ready = 1;
        start = 1;
        #10;
        start = 0;
        check_state(IDLE, "IDLE");
        
        // Kết thúc mô phỏng
        #20;
        $display("\n--- Simulation complete ---");
        $finish;
    end
    
    // Tạo file waveform để xem kết quả
    initial begin
        $dumpfile("des_control_unit_tb.vcd");
        $dumpvars(0, des_control_unit_tb);
    end

endmodule