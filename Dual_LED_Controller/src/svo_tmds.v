//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: TMDS encoder
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Oct 31 22:07:02 2023

`include "svo_defines.vh"

module svo_tmds
(
    input             resetn,
    input             clk,
    input      [7:0]  din,
    input      [1:0]  ctrl,
    input             de,
    output reg [9:0]  dout
);

wire reset = ~resetn;

reg [3:0] b_cnt, b_cnt_n;
reg [9:0] q_m, q_m_n;
reg [8:0] cnt, cnt_n;

function [3:0] count_one;
    input [7:0] data;
    integer i;
    begin
        count_one = 0;
        for (i = 0; i < 8; i = i + 1) begin
            count_one = count_one + data[i];
        end
    end
endfunction

function [3:0] count_one_q_m;
    input [7:0] data;
    integer i;
    begin
        count_one_q_m = 0;
        for (i = 0; i < 8; i = i + 1) begin
            count_one_q_m = count_one_q_m + data[i];
        end
    end
endfunction

always @(*) begin
    b_cnt_n = count_one(din);
    
    if ((b_cnt_n > 4) || ((b_cnt_n == 4) && (din[0] == 0))) begin
        q_m_n[0] = din[0];
        q_m_n[1] = q_m_n[0] ~^ din[1];
        q_m_n[2] = q_m_n[1] ~^ din[2];
        q_m_n[3] = q_m_n[2] ~^ din[3];
        q_m_n[4] = q_m_n[3] ~^ din[4];
        q_m_n[5] = q_m_n[4] ~^ din[5];
        q_m_n[6] = q_m_n[5] ~^ din[6];
        q_m_n[7] = q_m_n[6] ~^ din[7];
        q_m_n[8] = 0;
        q_m_n[9] = 0;
    end else begin
        q_m_n[0] = din[0];
        q_m_n[1] = q_m_n[0] ^ din[1];
        q_m_n[2] = q_m_n[1] ^ din[2];
        q_m_n[3] = q_m_n[2] ^ din[3];
        q_m_n[4] = q_m_n[3] ^ din[4];
        q_m_n[5] = q_m_n[4] ^ din[5];
        q_m_n[6] = q_m_n[5] ^ din[6];
        q_m_n[7] = q_m_n[6] ^ din[7];
        q_m_n[8] = 1;
        q_m_n[9] = 0;
    end
end

wire [3:0] b_cnt_q_m = count_one_q_m(q_m[7:0]);

always @(*) begin
    if (de == 0) begin
        case (ctrl)
            2'b00: cnt_n = cnt;
            2'b01: cnt_n = cnt;
            2'b10: cnt_n = cnt;
            2'b11: cnt_n = cnt;
            default: cnt_n = cnt;
        endcase
    end else begin
        if ((cnt == 0) || (b_cnt_q_m == 4)) begin
            if (q_m[8] == 0) begin
                cnt_n = cnt + 4 - b_cnt_q_m;
            end else begin
                cnt_n = cnt + b_cnt_q_m - 4;
            end
        end else begin
            if (((cnt > 0) && (b_cnt_q_m > 4)) || ((cnt < 0) && (b_cnt_q_m < 4))) begin
                // Sử dụng biến tạm thời để tránh lỗi cú pháp
                cnt_n = cnt + {q_m[8], 1'b0} + 4 - b_cnt_q_m;
            end else begin
                // Sử dụng biến tạm thời để tránh lỗi cú pháp
                cnt_n = cnt - {~q_m[8], 1'b0} + b_cnt_q_m - 4;
            end
        end
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cnt <= 0;
        q_m <= 0;
        dout <= 0;
    end else begin
        cnt <= cnt_n;
        q_m <= q_m_n;
        
        if (de == 0) begin
            case (ctrl)
                2'b00: dout <= 10'b1101010100;
                2'b01: dout <= 10'b0010101011;
                2'b10: dout <= 10'b0101010100;
                2'b11: dout <= 10'b1010101011;
                default: dout <= 10'b1101010100;
            endcase
        end else begin
            if ((cnt == 0) || (b_cnt_q_m == 4)) begin
                dout[9] <= ~q_m[8];
                dout[8] <= q_m[8];
                dout[7:0] <= q_m[8] ? q_m[7:0] : ~q_m[7:0];
            end else begin
                if (((cnt > 0) && (b_cnt_q_m > 4)) || ((cnt < 0) && (b_cnt_q_m < 4))) begin
                    dout[9] <= 1;
                    dout[8] <= q_m[8];
                    dout[7:0] <= ~q_m[7:0];
                end else begin
                    dout[9] <= 0;
                    dout[8] <= q_m[8];
                    dout[7:0] <= q_m[7:0];
                end
            end
        end
    end
end

endmodule 