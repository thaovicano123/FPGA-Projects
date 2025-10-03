`timescale 1ns/1ps

module des_full_tb();

    // Định nghĩa các tín hiệu
    reg clk;
    reg rst_n;
    reg start;
    reg encrypt;  // 1: Mã hóa, 0: Giải mã
    reg [63:0] data_in;
    reg [63:0] key;
    
    wire [63:0] data_out;
    wire done;
    wire error;
    wire [4:0] round_count;
    wire [3:0] state;
    
    // Theo dõi dữ liệu trong quá trình mã hóa
    integer cycle_count = 0;
    
    // Instantiate DES module đầy đủ
    des_datapath_and_control dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .encrypt(encrypt),
        .data_in(data_in),
        .key(key),
        .data_out(data_out),
        .done(done),
        .error(error)
    );
    
    // Theo dõi các tín hiệu bên trong DES module
    wire [31:0] left = dut.left;
    wire [31:0] right = dut.right;
    wire [31:0] feistel_out = dut.feistel_out;
    wire [47:0] subkey = dut.subkey;
    
    // Trích xuất control state và round count
    assign state = dut.state;
    assign round_count = dut.round_count;
    
    // Tạo tín hiệu đồng hồ 10ns (100MHz)
    always #5 clk = ~clk;
    
    // Hiển thị thông tin mỗi chu kỳ
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
        
        $display("Cycle %0d: State = %0d, Round = %0d", cycle_count, state, round_count);
        
        if (state == 4'd5) begin // SBOX state
            $display("  Data: Left = %h, Right = %h", left, right);
            $display("  Subkey for round %0d: %h", round_count, subkey);
            $display("  Feistel output: %h", feistel_out);
        end
        
        if (done) begin
            $display("DONE! Final output: %h", data_out);
        end
    end
    
    // Khối initial chứa các test case
    initial begin
        // Khởi tạo giá trị
        $display("\n=== TEST: DES Encryption/Decryption ===");
        clk = 0;
        rst_n = 0;
        start = 0;
        encrypt = 1; // Bắt đầu với mã hóa
        data_in = 64'h0123456789ABCDEF; // Dữ liệu mẫu
        key = 64'h133457799BBCDFF1; // Khóa mẫu DES tiêu chuẩn
        
        // Reset
        #20 rst_n = 1;
        
        // Bắt đầu quá trình mã hóa
        $display("\n--- Starting Encryption ---");
        #10 start = 1;
        #10 start = 0;
        
        // Đợi cho đến khi mã hóa hoàn thành
        wait(done);
        
        // Lưu kết quả mã hóa
        #10;
        $display("Encryption completed!");
        $display("Plaintext:  %h", data_in);
        $display("Key:        %h", key);
        $display("Ciphertext: %h", data_out);
        
        // Reset để chuẩn bị cho giải mã
        #10;
        rst_n = 0;
        #20 rst_n = 1;
        
        // Bắt đầu quá trình giải mã
        $display("\n--- Starting Decryption ---");
        encrypt = 0; // Chuyển sang giải mã
        data_in = data_out; // Sử dụng kết quả mã hóa làm đầu vào
        #10 start = 1;
        #10 start = 0;
        
        // Đợi cho đến khi giải mã hoàn thành
        wait(done);
        
        // Kiểm tra kết quả giải mã
        #10;
        $display("Decryption completed!");
        $display("Ciphertext: %h", data_in);
        $display("Key:        %h", key);
        $display("Plaintext:  %h", data_out);
        
        // Kiểm tra xem giải mã có khôi phục dữ liệu gốc không
        if (data_out == 64'h0123456789ABCDEF)
            $display("SUCCESS: Decryption recovered the original plaintext!");
        else
            $display("FAIL: Decryption did not recover the original plaintext!");
            
        // Kết thúc mô phỏng
        #20;
        $display("\n=== Simulation complete ===");
        $finish;
    end
    
    // Tạo file waveform để xem kết quả
    initial begin
        $dumpfile("des_full_tb.vcd");
        $dumpvars(0, des_full_tb);
    end

endmodule