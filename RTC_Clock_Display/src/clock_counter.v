module clock_counter (
    input wire clk,
    input wire rst,
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour
);

    // Thá»i gian khá»Ÿi táº¡o - Cáº­p nháº­t vá»›i thá»i gian hiá»‡n táº¡i
    // Cáº­p nháº­t lĂºc 15:35 ngĂ y hĂ´m nay
    localparam INIT_HOUR = 5'd16;   // Giá» khá»Ÿi táº¡o: 15 (3:00 PM)
    localparam INIT_MIN = 6'd15;    // PhĂºt khá»Ÿi táº¡o: 35
    localparam INIT_SEC = 6'd52;     // GiĂ¢y khá»Ÿi táº¡o: 0

    reg [25:0] tick;
    
    // Äáº¿m Ä‘á»ƒ Ä‘á»“ng há»“ cháº¡y á»Ÿ tá»‘c Ä‘á»™ thá»i gian thá»±c
    // 27MHz / 27,000,000 = 1Hz (1 giĂ¢y/tick)
    // Äá»“ng há»“ sáº½ cháº¡y Ä‘Ăºng vá»›i thá»i gian thá»±c
    localparam TICK_MAX = 26'd27000000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tick <= 0;
            // Khá»Ÿi táº¡o vá»›i thá»i gian hiá»‡n táº¡i thay vĂ¬ 00:00:00
            sec <= INIT_SEC;
            min <= INIT_MIN;
            hour <= INIT_HOUR;
        end else begin
            if (tick == TICK_MAX - 1) begin
                tick <= 0;
                if (sec == 6'd59) begin
                    sec <= 0;
                    if (min == 6'd59) begin
                        min <= 0;
                        if (hour == 5'd23)
                            hour <= 0;
                        else
                            hour <= hour + 1;
                    end else
                        min <= min + 1;
                end else
                    sec <= sec + 1;
            end else begin
                tick <= tick + 1;
            end
        end
    end
endmodule




