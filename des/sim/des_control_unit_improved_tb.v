module des_control_unit_improved_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg start;
    reg mode;
    wire ready;
    wire load_input;
    wire store_output;
    wire [3:0] round;
    wire init_perm_en;
    wire final_perm_en;
    wire key_shift_en;
    wire key_perm_en;
    wire expansion_en;
    wire xor_en;
    wire sbox_en;
    wire p_box_en;
    wire lr_swap_en;
    
    // Test process tracking
    integer i;
    reg test_complete;
    
    // DUT Instantiation
    des_control_unit_improved dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .mode(mode),
        .ready(ready),
        .load_input(load_input),
        .store_output(store_output),
        .round(round),
        .init_perm_en(init_perm_en),
        .final_perm_en(final_perm_en),
        .key_shift_en(key_shift_en),
        .key_perm_en(key_perm_en),
        .expansion_en(expansion_en),
        .xor_en(xor_en),
        .sbox_en(sbox_en),
        .p_box_en(p_box_en),
        .lr_swap_en(lr_swap_en)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        start = 0;
        mode = 0; // Encryption mode
        test_complete = 0;
        
        // Display header
        $display("=== Testing DES Control Unit (Improved Version) ===");
        $display("Time\tState\tRound\tControl Signals");
        
        // Reset sequence
        #20 reset = 0;
        
        // Wait for initial ready state
        wait(ready);
        $display("%0t\tIDLE\t-\tReady for operation", $time);
        
        // Start encryption process
        #10 start = 1;
        #10 start = 0;
        
        // Wait for operation to complete
        wait(store_output);
        $display("%0t\tCOMPLETE\t%0d\tEncryption complete", $time, round);
        
        // Let it return to idle
        wait(ready);
        
        // Switch to decryption mode
        #20;
        mode = 1; // Decryption mode
        $display("\n=== Testing Decryption Mode ===");
        
        // Start decryption process
        #10 start = 1;
        #10 start = 0;
        
        // Wait for operation to complete
        wait(store_output);
        $display("%0t\tCOMPLETE\t%0d\tDecryption complete", $time, round);
        
        // Let it return to idle
        wait(ready);
        
        // Finish simulation
        test_complete = 1;
        #20 $finish;
    end
    
    // Signal monitoring
    always @(posedge clk) begin
        if (init_perm_en)
            $display("%0t\tINIT_PERM\t-\tInitial Permutation", $time);
        
        if (key_shift_en)
            $display("%0t\tKEY_SHIFT\t%0d\tKey Shifting", $time, round);
            
        if (key_perm_en)
            $display("%0t\tKEY_PERM\t%0d\tKey Permutation", $time, round);
            
        if (expansion_en)
            $display("%0t\tEXPANSION\t%0d\tExpansion", $time, round);
            
        if (xor_en && sbox_en)
            $display("%0t\tXOR+SBOX\t%0d\tXOR and S-Box", $time, round);
            
        if (p_box_en)
            $display("%0t\tP_BOX\t%0d\tPermutation", $time, round);
            
        if (lr_swap_en)
            $display("%0t\tLR_SWAP\t%0d\tL-R Swap", $time, round);
            
        if (final_perm_en)
            $display("%0t\tFINAL_PERM\t%0d\tFinal Permutation", $time, round);
    end
    
    // Save waveform
    initial begin
        $dumpfile("des_control_unit_improved.vcd");
        $dumpvars(0, des_control_unit_improved_tb);
    end
    
    // Verify test completion
    initial begin
        #10000; // Timeout
        if (!test_complete)
            $display("ERROR: Test timed out!");
        $finish;
    end
endmodule