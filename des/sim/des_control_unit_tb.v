module des_control_unit_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg start;
    wire ready;
    wire [3:0] round;
    wire init_perm;
    wire key_gen;
    wire round_op;
    wire final_perm;
    
    // DUT Instantiation
    des_control_unit dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ready(ready),
        .round(round),
        .init_perm(init_perm),
        .key_gen(key_gen),
        .round_op(round_op),
        .final_perm(final_perm)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        start = 0;
        
        // Reset sequence
        #20 reset = 0;
        
        // Wait a bit and start
        #10 start = 1;
        #10 start = 0;
        
        // Wait for completion
        wait(ready);
        
        // Start again to test reusability
        #20 start = 1;
        #10 start = 0;
        
        // Wait for completion
        wait(ready);
        
        // Finish simulation
        #20 $finish;
    end
    
    // Monitoring
    initial begin
        $monitor("Time=%0t, State: ready=%b, round=%d, init_perm=%b, key_gen=%b, round_op=%b, final_perm=%b",
                $time, ready, round, init_perm, key_gen, round_op, final_perm);
    end
endmodule