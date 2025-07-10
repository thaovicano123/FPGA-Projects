//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: HDMI output module
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Oct 31 22:07:02 2023

`include "svo_defines.vh"

module svo_hdmi
(
    input             rst_n,
    input             pix_clk,         // pixel clock
    input             ser_clk,         // serializer clock
    
    input             vs_in,
    input             hs_in,
    input             de_in,
    input      [7:0]  r_in,
    input      [7:0]  g_in,
    input      [7:0]  b_in,
    
    output            tmds_clk_p,
    output            tmds_clk_n,
    output     [2:0]  tmds_data_p,
    output     [2:0]  tmds_data_n
);

wire reset = ~rst_n;

// TMDS encoding
wire [9:0] tmds_data_ch0, tmds_data_ch1, tmds_data_ch2;

svo_tmds tmds_ch0 (
    .reset(reset),
    .clk(pix_clk),
    .data(b_in),
    .ctrl({vs_in, hs_in}),
    .de(de_in),
    .q_out(tmds_data_ch0)
);

svo_tmds tmds_ch1 (
    .reset(reset),
    .clk(pix_clk),
    .data(g_in),
    .ctrl(2'b00),
    .de(de_in),
    .q_out(tmds_data_ch1)
);

svo_tmds tmds_ch2 (
    .reset(reset),
    .clk(pix_clk),
    .data(r_in),
    .ctrl(2'b00),
    .de(de_in),
    .q_out(tmds_data_ch2)
);

// Serializer
wire [2:0] tmds_data_serial;
wire tmds_clk_serial;

// Simple serializer implementation
reg [9:0] shift_ch0, shift_ch1, shift_ch2;
reg [9:0] shift_clk;
reg [3:0] bit_cnt;

always @(posedge ser_clk or posedge reset) begin
    if (reset) begin
        shift_ch0 <= 0;
        shift_ch1 <= 0;
        shift_ch2 <= 0;
        shift_clk <= 10'b0000011111;
        bit_cnt <= 0;
    end else begin
        bit_cnt <= bit_cnt + 1;
        
        if (bit_cnt == 9) begin
            // Load new data
            shift_ch0 <= tmds_data_ch0;
            shift_ch1 <= tmds_data_ch1;
            shift_ch2 <= tmds_data_ch2;
            shift_clk <= 10'b0000011111;
        end else begin
            // Shift out data
            shift_ch0 <= {1'b0, shift_ch0[9:1]};
            shift_ch1 <= {1'b0, shift_ch1[9:1]};
            shift_ch2 <= {1'b0, shift_ch2[9:1]};
            shift_clk <= {1'b0, shift_clk[9:1]};
        end
    end
end

assign tmds_data_serial[0] = shift_ch0[0];
assign tmds_data_serial[1] = shift_ch1[0];
assign tmds_data_serial[2] = shift_ch2[0];
assign tmds_clk_serial = shift_clk[0];

// Differential output buffers
assign tmds_clk_p = tmds_clk_serial;
assign tmds_clk_n = ~tmds_clk_serial;
assign tmds_data_p = tmds_data_serial;
assign tmds_data_n = ~tmds_data_serial;

endmodule 