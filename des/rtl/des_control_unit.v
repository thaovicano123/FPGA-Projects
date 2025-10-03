module des_control_unit(
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire start,        // Start signal to begin encryption/decryption
    output reg ready,        // Ready signal indicating operation completion
    output reg [3:0] round,  // Current round (0-15)
    output reg init_perm,    // Control signal for Initial Permutation
    output reg key_gen,      // Control signal for Key Generation
    output reg round_op,     // Control signal for Round Operations
    output reg final_perm    // Control signal for Final Permutation
);

    // FSM state definitions
    localparam IDLE      = 2'b00;
    localparam INIT      = 2'b01;
    localparam ROUNDS    = 2'b10;
    localparam FINAL     = 2'b11;

    // Internal registers
    reg [1:0] state, next_state;
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

    // FSM: Next state logic
    always @(*) begin
        next_state = state;  // Default: stay in current state
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = INIT;
            end
            
            INIT: begin
                next_state = ROUNDS;
            end
            
            ROUNDS: begin
                if (round_complete)
                    next_state = FINAL;
            end
            
            FINAL: begin
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
        end else if (state == ROUNDS) begin
            if (round_counter < 4'd15) begin
                round_counter <= round_counter + 1'b1;
                round_complete <= 1'b0;
            end else begin
                round_complete <= 1'b1;
            end
        end else if (state == IDLE) begin
            round_counter <= 4'd0;
            round_complete <= 1'b0;
        end
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            round <= 4'd0;
            ready <= 1'b0;
            init_perm <= 1'b0;
            key_gen <= 1'b0;
            round_op <= 1'b0;
            final_perm <= 1'b0;
        end else begin
            // Default values
            ready <= 1'b0;
            init_perm <= 1'b0;
            key_gen <= 1'b0;
            round_op <= 1'b0;
            final_perm <= 1'b0;
            
            case (state)
                IDLE: begin
                    ready <= 1'b1;
                end
                
                INIT: begin
                    init_perm <= 1'b1;
                    key_gen <= 1'b1;  // Initial key permutation
                end
                
                ROUNDS: begin
                    round <= round_counter;
                    key_gen <= 1'b1;  // Key generation for current round
                    round_op <= 1'b1; // Round operations
                end
                
                FINAL: begin
                    final_perm <= 1'b1;
                end
            endcase
        end
    end

endmodule