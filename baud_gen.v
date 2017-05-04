/* Module Baud Generator generate 
 * constant interval tick for TX and RX oversampling UART Signals
 * TX/RX block oversampling 16 times of baudrate
 */
module baud_gen
    #(parameter
        f_clk = 50_000_000,
        f_baud = 38400
    )
    (
        input clk, reset,
        output oTick
    );
    localparam [7:0] count_max = f_clk/(f_baud*16); 
    
    reg [7:0] count_reg, count_next;
    reg tick;
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            count_reg <= count_max;
        end
        else begin
            count_reg <= count_next;
        end
    end
    always@* begin
        count_next = count_reg - 1;
        tick = 1'b0;
        if(count_reg == 0) begin
            count_next = count_max;
            tick = 1'b1;
        end
    end
    assign oTick = tick;

endmodule
