/* Top Level Verilog File of UART Module
 */
module uart_module_top
    #(parameter
        f_clk = 50_000_000,
        f_baud = 115200
    )
    (
        input clk, reset,
        input iRX,
        output oTX,
        /* RX Side */
        output [7:0] rx_data,
        input rx_rd,
        output rx_empty,
        output rx_err,
        /* TX Side */
        input [7:0] tx_data,
        input tx_wrt,
        output tx_full,
        output tx_err
    );

    /* Signal Declaration */
    wire baud_tick;
    wire rx_done;
    wire [7:0] rx_fifo_data;
    wire [7:0] tx_fifo_data;
    wire tx_done;
    wire tx_start;
    wire tx_fifo_empty;

    /* Baud Rate Generator */
    baud_gen 
    #(
        .f_clk(f_clk),
        .f_baud(f_baud)
    ) baud_gen_inst
    (
        .clk(clk),
        .reset(reset),
        .oTick(baud_tick)
    );

    /* RX Block and its FIFO */
    rx_uart rx_uart_inst
    (
        .clk(clk), 
        .reset(reset),
        .iRX(iRX),
        .iBaud_tick(baud_tick),
        .oDone_tick(rx_done),
        .oErr(rx_err),
        .oData(rx_fifo_data)
    );

    fifo 
    #(
        .B(8),   /* Number of data bits */
        .W(4)    /* Number of Address bits */
    ) rx_fifo_inst
    (   /* IO Signals */
        .clk(clk), 
        .reset(reset),
        /* Write side */
        .w_en(rx_done),
        .w_data(rx_fifo_data),
        .w_full(),
        /* Read side */
        .r_en(rx_rd),
        .r_data(rx_data),
        .r_empty(rx_empty)
    );

    /* TX Block and its FIFO */
    tx_uart tx_uart_inst
    (
        .clk(clk), 
        .reset(reset),
        .oTX(oTX),
        .iBaud_tick(baud_tick),
        .oDone_tick(tx_done),
        .oErr(tx_err),
        .iData(tx_fifo_data),
        .iStart(tx_start) 
    );

    assign tx_start = ~tx_fifo_empty;

    fifo 
     #(
        .B(8),   /* Number of data bits */
        .W(4)    /* Number of Address bits */
    ) tx_fifo_inst
    (   /* IO Signals */
        .clk(clk), 
        .reset(reset),
        /* Write side */
        .w_en(tx_wrt),
        .w_data(tx_data),
        .w_full(tx_full),
        /* Read side */
        .r_en(tx_done),
        .r_data(tx_fifo_data),
        .r_empty(tx_fifo_empty)
    );

endmodule
