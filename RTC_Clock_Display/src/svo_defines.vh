//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Video/HDMI defines
//GOWIN Version: V1.9.9 Beta-4 Education
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Oct 31 22:07:02 2023

`ifndef SVO_DEFINES_VH
`define SVO_DEFINES_VH

// Video timing parameters for 640x480@60Hz
`define H_ACTIVE    640
`define H_FP        16
`define H_SYNC      96
`define H_BP        48
`define H_TOTAL     800

`define V_ACTIVE    480
`define V_FP        10
`define V_SYNC      2
`define V_BP        33
`define V_TOTAL     525

// TMDS encoding constants
`define TMDS_CTRL_00    10'b1101010100
`define TMDS_CTRL_01    10'b0010101011
`define TMDS_CTRL_10    10'b0101010100
`define TMDS_CTRL_11    10'b1010101011

`endif // SVO_DEFINES_VH

