// Reset Synchronizer
// Synchronizes the deassertion of reset to the clock domain

module Reset_Sync (
    output reg resetn,
    input wire ext_reset,
    input wire clk
);

reg resetn_sync;

always @(posedge clk or negedge ext_reset) begin
    if (~ext_reset) begin
        resetn_sync <= 1'b0;
        resetn <= 1'b0;
    end else begin
        resetn_sync <= 1'b1;
        resetn <= resetn_sync;
    end
end

endmodule 