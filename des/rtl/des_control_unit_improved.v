module des_control_unit_improved(
    input wire clk,              // Clock signal
    input wire reset,            // Reset signal
    input wire start,            // Start signal to begin encryption/decryption
    input wire mode,             // Mode: 0 for encryption, 1 for decryption
    output reg ready,            // Ready signal indicating operation completion
    output reg load_input,       // Control signal to load input data
    output reg store_output,     // Control signal to store output data
    output reg [3:0] round,      // Current round (0-15)
    output reg init_perm_en,     // Enable Initial Permutation
    output reg final_perm_en,    // Enable Final Permutation
    output reg key_shift_en,     // Enable Key Shifting
    output reg key_perm_en,      // Enable Key Permutation
    output reg expansion_en,     // Enable Expansion
    output reg xor_en,           // Enable XOR operation
    output reg sbox_en,          // Enable S-Box substitution
    output reg p_box_en,         // Enable P-Box permutation
    output reg lr_swap_en        // Enable L-R Swap
);

    // FSM state definitions - more detailed for proper sequencing
    localparam IDLE          = 4'd0;
    localparam LOAD_DATA     = 4'd1;
    localparam INIT_PERM     = 4'd2;
    localparam KEY_INIT      = 4'd3;
    localparam ROUND_START   = 4'd4;
    localparam KEY_SHIFT     = 4'd5;
    localparam KEY_PERM      = 4'd6;
    localparam EXPANSION     = 4'd7;
    localparam XOR_SBOX      = 4'd8;
    localparam P_BOX         = 4'd9;
    localparam LR_SWAP       = 4'd10;
    localparam FINAL_PERM    = 4'd11;
    localparam COMPLETE      = 4'd12;

    // Internal registers
    reg [3:0] state, next_state;
    reg [3:0] round_counter;
    reg round_complete;

    // FSM: State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM: Next state logic with detailed sequencing
    always @(*) begin
        next_state = state;  // Default: stay in current state
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = LOAD_DATA;
            end
            
            LOAD_DATA: begin
                next_state = INIT_PERM;
            end
            
            INIT_PERM: begin
                next_state = KEY_INIT;
            end
            
            KEY_INIT: begin
                next_state = ROUND_START;
            end
            
            ROUND_START: begin
                next_state = KEY_SHIFT;
            end
            
            KEY_SHIFT: begin
                next_state = KEY_PERM;
            end
            
            KEY_PERM: begin
                next_state = EXPANSION;
            end
            
            EXPANSION: begin
                next_state = XOR_SBOX;
            end
            
            XOR_SBOX: begin
                next_state = P_BOX;
            end
            
            P_BOX: begin
                if (round_counter == 4'd15) // Last round
                    next_state = FINAL_PERM;
                else
                    next_state = LR_SWAP;
            end
            
            LR_SWAP: begin
                next_state = ROUND_START;
            end
            
            FINAL_PERM: begin
                next_state = COMPLETE;
            end
            
            COMPLETE: begin
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Round counter logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            round_counter <= 4'd0;
            round_complete <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    round_counter <= 4'd0;
                    round_complete <= 1'b0;
                end
                
                ROUND_START: begin
                    round <= round_counter;
                end
                
                LR_SWAP: begin
                    round_counter <= round_counter + 1'b1;
                end
                
                P_BOX: begin
                    if (round_counter == 4'd15)
                        round_complete <= 1'b1;
                end
            endcase
        end
    end

    // Output logic with proper control signal timing
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ready <= 1'b1;         // Ready to start after reset
            load_input <= 1'b0;
            store_output <= 1'b0;
            init_perm_en <= 1'b0;
            final_perm_en <= 1'b0;
            key_shift_en <= 1'b0;
            key_perm_en <= 1'b0;
            expansion_en <= 1'b0;
            xor_en <= 1'b0;
            sbox_en <= 1'b0;
            p_box_en <= 1'b0;
            lr_swap_en <= 1'b0;
        end else begin
            // Default values - all control signals off
            ready <= 1'b0;
            load_input <= 1'b0;
            store_output <= 1'b0;
            init_perm_en <= 1'b0;
            final_perm_en <= 1'b0;
            key_shift_en <= 1'b0;
            key_perm_en <= 1'b0;
            expansion_en <= 1'b0;
            xor_en <= 1'b0;
            sbox_en <= 1'b0;
            p_box_en <= 1'b0;
            lr_swap_en <= 1'b0;
            
            case (state)
                IDLE: begin
                    ready <= 1'b1;
                end
                
                LOAD_DATA: begin
                    load_input <= 1'b1;
                end
                
                INIT_PERM: begin
                    init_perm_en <= 1'b1;
                end
                
                KEY_INIT: begin
                    key_perm_en <= 1'b1;
                end
                
                KEY_SHIFT: begin
                    key_shift_en <= 1'b1;
                end
                
                KEY_PERM: begin
                    key_perm_en <= 1'b1;
                end
                
                EXPANSION: begin
                    expansion_en <= 1'b1;
                end
                
                XOR_SBOX: begin
                    xor_en <= 1'b1;
                    sbox_en <= 1'b1;
                end
                
                P_BOX: begin
                    p_box_en <= 1'b1;
                end
                
                LR_SWAP: begin
                    lr_swap_en <= 1'b1;
                end
                
                FINAL_PERM: begin
                    final_perm_en <= 1'b1;
                end
                
                COMPLETE: begin
                    store_output <= 1'b1;
                    ready <= 1'b1;
                end
            endcase
        end
    end

endmodule