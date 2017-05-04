module fifo
    #(parameter
        B = 8, /* Number of data bits */
        W = 4  /* Number of Address bits */
    )
    (   /* IO Signals */
        input clk, reset,
        /* Write side */
        input w_en,
        input [B-1:0] w_data,
        output w_full,
        /* Read side */
        input r_en,
        output [B-1:0] r_data,
        output r_empty
    );

    reg [B-1:0] array_reg [W**2-1:0];
    reg full_reg, full_next;
    reg empty_reg, empty_next;
    reg [W-1:0] w_ptr_next, w_ptr_reg, w_ptr_succ;
    reg [W-1:0] r_ptr_next, r_ptr_reg, r_ptr_succ;
    wire w_enable;

    /* FIFO Control Part */
    /* D flip-flop */
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
        end /* if */
        else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end /* else */
    end /* always block */

    /* Next state logic */
    always@* begin
        w_ptr_succ = w_ptr_reg + 1;
        r_ptr_succ = r_ptr_reg + 1;
        /* default value */
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;
        case ({w_en, r_en})
            2'b00: begin /* no op */
				end
            2'b01: begin /* Read */
                if(~empty_reg) begin
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if(r_ptr_succ==w_ptr_reg)
                        empty_next = 1'b1;
                end /* if */
				end /* 2'b01 */
            2'b10: begin /* Write */
                if(~full_reg) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if(w_ptr_succ==r_ptr_reg)
                        full_next = 1'b1;
                end /* if */
				end /* 2'b10 */
            default: begin/* Read Write at the same time */
                w_ptr_next = w_ptr_succ;
                w_ptr_next = w_ptr_succ;
				end /* Default */
        endcase
    end /* always block */
    assign r_empty = empty_reg;
    assign w_full = full_reg;

    /* Array Write Operation */
    assign w_enable = (w_en & ~full_reg);
    always@(posedge clk) begin
        if (w_enable)
            array_reg[w_ptr_reg] <= w_data;
    end
    /* Array Read Operation */
    assign r_data = array_reg[r_ptr_reg];

endmodule
