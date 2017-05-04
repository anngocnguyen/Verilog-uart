/* This is the TX block of UART module
 * Made by: An Nguyen
 * Date: 01st May, 2017
 */
module tx_uart 
    (
        input clk, reset,
        output oTX,
        input iBaud_tick,
        output oDone_tick,
        output oErr,
        input [7:0] iData,
        input iStart 
    );

    /* State Definition */
    localparam  s_idle = 0,
                s_start = 1,
                s_tranmitt = 2,
                s_stop = 3,
                s_err = 4;

    /* Variable Declaration */
    reg [3:0] state_reg, state_next;
    reg [7:0] data_reg, data_next;
    reg [7:0] baud_count_reg, baud_count_next;
    reg [7:0] bit_count_reg, bit_count_next;
    reg err;
    reg done_tick;
    reg tx;

    /* FSM Control Transmitt Process */
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            state_reg <= s_idle;
            data_reg <= 'b0;
            baud_count_reg <= 8'd15;
            bit_count_reg <= 8'd7;
        end
        else begin
            state_reg <= state_next;
            data_reg <= data_next;
            baud_count_reg <= baud_count_next;
            bit_count_reg <= bit_count_next;
        end
    end
    /* */
    always@* begin
        state_next = state_reg;
        data_next = data_reg;
        baud_count_next = baud_count_reg;
        bit_count_next = bit_count_reg;
        err = 1'b0;
        done_tick = 1'b0;
        tx = 1'b1;
        case(state_reg)
            s_idle: begin
                if(iStart) begin
                    state_next = s_start;
                    data_next = iData;
                    bit_count_next = 8'd7;
                end
            end
            s_start: begin
                tx = 1'b0;
                if(iBaud_tick) begin
                    if(baud_count_reg == 0) begin
                        baud_count_next = 8'd15;
                        state_next = s_tranmitt;
                    end
                    else begin
                        baud_count_next = baud_count_reg - 1;
                    end
                end
            end
            s_tranmitt: begin
                tx = data_reg[0];
                if(iBaud_tick) begin
                    if(baud_count_reg == 0) begin
                        baud_count_next = 8'd15;
                        data_next = {1'b0, data_reg[7:1]};
                        if(bit_count_reg == 0) begin
                            state_next = s_stop;
                        end
                        else begin
                            bit_count_next = bit_count_reg - 1;
                        end
                    end
                    else begin
                        baud_count_next = baud_count_reg - 1;
                    end
                end
            end
            s_stop: begin
                tx = 1'b1;
                if(iBaud_tick) begin
                    if(baud_count_reg == 0) begin
                        baud_count_next = 8'd15;
                        state_next = s_idle;
                        done_tick = 1'b1;
                    end
                    else begin
                        baud_count_next = baud_count_reg - 1;
                    end
                end
            end
            s_err: begin
                err = 1'b1;
            end
        endcase
    end

    assign oErr = err;
    assign oDone_tick = done_tick;
    assign oTX = tx;
endmodule
