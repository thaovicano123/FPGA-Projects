// Video Timing Generator for 640x480@60Hz
module video_timing (
    input wire clk,
    input wire resetn,
    output reg [9:0] x,
    output reg [9:0] y,
    output wire hsync,
    output wire vsync,
    output wire de
);

// VGA 640x480@60Hz timing parameters
localparam H_ACTIVE = 640;
localparam H_FP = 16;
localparam H_SYNC = 96;
localparam H_BP = 48;
localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP; // 800

localparam V_ACTIVE = 480;
localparam V_FP = 10;
localparam V_SYNC = 2;
localparam V_BP = 33;
localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP; // 525

reg [9:0] h_count, v_count;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        h_count <= 0;
        v_count <= 0;
        x <= 0;
        y <= 0;
    end else begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1) begin
                v_count <= 0;
            end else begin
                v_count <= v_count + 1;
            end
        end else begin
            h_count <= h_count + 1;
        end
        
        // Output pixel coordinates (active area only)
        if (h_count < H_ACTIVE && v_count < V_ACTIVE) begin
            x <= h_count;
            y <= v_count;
        end else begin
            x <= 0;
            y <= 0;
        end
    end
end

// Generate sync signals
assign hsync = ~((h_count >= H_ACTIVE + H_FP) && (h_count < H_ACTIVE + H_FP + H_SYNC));
assign vsync = ~((v_count >= V_ACTIVE + V_FP) && (v_count < V_ACTIVE + V_FP + V_SYNC));

// Data enable signal
assign de = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

endmodule 