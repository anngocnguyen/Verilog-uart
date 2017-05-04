/* This is the RX block of UART module
 * Written by: An Nguyen
 * Date: 1st May, 2017
 */
module rx_uart 
    (
        input clk, reset,
        input iRX,
        input iBaud_tick,
        output oDone_tick,
        output oErr,
        output [7:0] oData
    );

    /* State Defination */
    localparam  s_idle = 0,
                s_start = 1,
                s_receive = 2,
                s_stop = 3,
                s_err = 4;

    /* Variable Declaration */
    reg [3:0] state_reg, state_next;
    reg [7:0] bit_count_reg, bit_count_next;
    reg [7:0] baud_count_reg, baud_count_next;
    reg done_tick;
    reg err;
    reg [7:0] data_reg, data_next;

    /* FSM to control UART Block */
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            state_reg <= s_idle;
            bit_count_reg <= 7;
            baud_count_reg <= 7;
            data_reg <= 'b0;
        end
        else begin
            state_reg <= state_next;
            bit_count_reg <= bit_count_next;
            baud_count_reg <= baud_count_next;
            data_reg <= data_next;
        end
    end
    /**/
    always@* begin
        state_next = state_reg;
        bit_count_next = bit_count_reg;
        baud_count_next = baud_count_reg;
        data_next = data_reg;
        done_tick = 1'b0;
        err = 1'b0;
        if(iBaud_tick) begin
            case(state_reg)
                s_idle: begin /* Idle State */
                    if (~iRX) begin
                        state_next = s_start;
                        baud_count_next = 7;
                    end
                end
                s_start: begin /* Start State */
                    if(baud_count_reg == 0) begin
                        state_next = s_receive;
                        baud_count_next = 8'd15;
                        bit_count_next = 8'd7;
                    end
                    else begin
                        baud_count_next = baud_count_reg - 8'd1;
                    end
                end
                s_receive: begin /* Retrieve Data */
                    if(baud_count_reg == 0) begin
                        baud_count_next = 8'd15;
                        data_next = {iRX, data_reg[7:1]}; /* Shift new Comming Bit into RX Register */
                        if(bit_count_reg == 0) begin 
                            state_next = s_stop;
                        end
                        else begin 
                            bit_count_next = bit_count_reg - 8'd1;
                        end
                    end
                    else begin
                        baud_count_next = baud_count_reg - 8'd1;
                    end
                end
                s_stop: begin /* Wait for Stop Bit */
                    if(baud_count_reg == 0) begin
                        state_next = s_idle;
                        done_tick = 1'b1;
                    end
                    else begin
                        baud_count_next = baud_count_reg - 8'd1;
                    end
                end
                s_err: begin /* Error */
                    err = 1'b1;
                end
            endcase
        end
    end
    
    assign oDone_tick = done_tick;
    assign oErr = err;
    assign oData = data_reg;
endmodule
