module font_rom (
    input wire [4:0] char_code,   // 0–9, 10 = ':', 11 = '/', 12 = '-', 13 = ' ', 14-19 = 'C', 'o', 'u', 'n', 't', '='
    input wire [2:0] row,         // 0–7
    output reg [7:0] bitmap       // Một dòng của ký tự (8 pixel ngang)
);

    always @(*) begin
        bitmap = 8'b00000000;  // Mặc định

        case (char_code)
            5'd0: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b01101110;
                3: bitmap = 8'b01110110;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd1: case (row)
                0: bitmap = 8'b00011000;
                1: bitmap = 8'b00111000;
                2: bitmap = 8'b00011000;
                3: bitmap = 8'b00011000;
                4: bitmap = 8'b00011000;
                5: bitmap = 8'b00011000;
                6: bitmap = 8'b01111110;
                7: bitmap = 8'b00000000;
            endcase
            5'd2: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b00000110;
                3: bitmap = 8'b00001100;
                4: bitmap = 8'b00110000;
                5: bitmap = 8'b01100000;
                6: bitmap = 8'b01111110;
                7: bitmap = 8'b00000000;
            endcase
            5'd3: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b00000110;
                3: bitmap = 8'b00011100;
                4: bitmap = 8'b00000110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd4: case (row)
                0: bitmap = 8'b00001100;
                1: bitmap = 8'b00011100;
                2: bitmap = 8'b00111100;
                3: bitmap = 8'b01101100;
                4: bitmap = 8'b01111110;
                5: bitmap = 8'b00001100;
                6: bitmap = 8'b00001100;
                7: bitmap = 8'b00000000;
            endcase
            5'd5: case (row)
                0: bitmap = 8'b01111110;
                1: bitmap = 8'b01100000;
                2: bitmap = 8'b01111100;
                3: bitmap = 8'b00000110;
                4: bitmap = 8'b00000110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd6: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100000;
                2: bitmap = 8'b01111100;
                3: bitmap = 8'b01100110;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd7: case (row)
                0: bitmap = 8'b01111110;
                1: bitmap = 8'b00000110;
                2: bitmap = 8'b00001100;
                3: bitmap = 8'b00011000;
                4: bitmap = 8'b00110000;
                5: bitmap = 8'b00110000;
                6: bitmap = 8'b00110000;
                7: bitmap = 8'b00000000;
            endcase
            5'd8: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b01100110;
                3: bitmap = 8'b00111100;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd9: case (row)
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b01100110;
                3: bitmap = 8'b00111110;
                4: bitmap = 8'b00000110;
                5: bitmap = 8'b00000110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd10: case (row) // Colon ":"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b00011000;
                3: bitmap = 8'b00011000;
                4: bitmap = 8'b00000000;
                5: bitmap = 8'b00011000;
                6: bitmap = 8'b00011000;
                7: bitmap = 8'b00000000;
            endcase
            5'd11: case (row) // Slash "/"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000010;
                2: bitmap = 8'b00000100;
                3: bitmap = 8'b00001000;
                4: bitmap = 8'b00010000;
                5: bitmap = 8'b00100000;
                6: bitmap = 8'b01000000;
                7: bitmap = 8'b00000000;
            endcase
            5'd12: case (row) // Dash "-"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b00000000;
                3: bitmap = 8'b01111110;
                4: bitmap = 8'b00000000;
                5: bitmap = 8'b00000000;
                6: bitmap = 8'b00000000;
                7: bitmap = 8'b00000000;
            endcase
            5'd13: case (row) // Space " "
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b00000000;
                3: bitmap = 8'b00000000;
                4: bitmap = 8'b00000000;
                5: bitmap = 8'b00000000;
                6: bitmap = 8'b00000000;
                7: bitmap = 8'b00000000;
            endcase
            5'd14: case (row) // Letter "C"
                0: bitmap = 8'b00111100;
                1: bitmap = 8'b01100110;
                2: bitmap = 8'b01100000;
                3: bitmap = 8'b01100000;
                4: bitmap = 8'b01100000;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd15: case (row) // Letter "o"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b00111100;
                3: bitmap = 8'b01100110;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111100;
                7: bitmap = 8'b00000000;
            endcase
            5'd16: case (row) // Letter "u"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b01100110;
                3: bitmap = 8'b01100110;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b00111110;
                7: bitmap = 8'b00000000;
            endcase
            5'd17: case (row) // Letter "n"
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b01111100;
                3: bitmap = 8'b01100110;
                4: bitmap = 8'b01100110;
                5: bitmap = 8'b01100110;
                6: bitmap = 8'b01100110;
                7: bitmap = 8'b00000000;
            endcase
            5'd18: case (row) // Letter "t"
                0: bitmap = 8'b00010000;
                1: bitmap = 8'b00010000;
                2: bitmap = 8'b01111100;
                3: bitmap = 8'b00010000;
                4: bitmap = 8'b00010000;
                5: bitmap = 8'b00010110;
                6: bitmap = 8'b00001100;
                7: bitmap = 8'b00000000;
            endcase
            5'd19: case (row) // Equal sign "="
                0: bitmap = 8'b00000000;
                1: bitmap = 8'b00000000;
                2: bitmap = 8'b01111110;
                3: bitmap = 8'b00000000;
                4: bitmap = 8'b01111110;
                5: bitmap = 8'b00000000;
                6: bitmap = 8'b00000000;
                7: bitmap = 8'b00000000;
            endcase
            default: bitmap = 8'b00000000;
        endcase
    end
endmodule
