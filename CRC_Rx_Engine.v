
`define MASK 17'b10001000000100001
module CRC_Rx_Engine
(
    input   rx_i, 
            rx_en_i,
            clk_i,
            tick_i,
            rst_i,

    output reg [23:0] out_o = 0, 
    output reg done_o = 0,
    output reg error_o = 0
);
    wire [7:0]  RX_data;
    wire        RX_done, 
                RX_stop_bit; 

    // Instantiate Rx module
    UART_RX#(.N(8)) RX
    (
        .data_o(RX_data),
        .rx_done(RX_done),
        .stop_bit(RX_stop_bit),

        .rx_i(rx_i),
        .rx_en_i(rx_en_i),
        .tick_i(tick_i), 
        .clk_i(clk_i),
        .rst_i(rst_i)
    );


    wire [39:0] chk_din;
    wire chk_we, chk_out_valid;
    wire [15:0] checksum_out;

    checksum chk(
        .data_i(chk_din),
        .we_i(chk_we),
        .clk_i(clk_i),
        .rst_i(rst_i), 

        .mask_i(`MASK),

        .out_o(checksum_out),
        .out_valid_o(chk_out_valid)
    );


    reg [4:0] state = 0;

    /* 
        Byte counter, Counts 0 - 4
        0, 1, 2     -   message bytes
        3, 4        -   checksum bytes
    */
    reg [2:0] bytecount = 0;

    //byte count
    always @ (posedge tick_i) begin
        if(rst_i) begin
            bytecount <= 0;
            rx_data_reg_valid <= 0;
        end

        else if(bytecount == 5) begin
            bytecount <= 0;
            rx_data_reg_valid <= 1;
        end

        else if(RX_stop_bit)
            bytecount <= bytecount+1;
    end

    wire [7:0] RX_data_reversed = {RX_data[0], RX_data[1], RX_data[2], RX_data[3], RX_data[4], RX_data[5], RX_data[6], RX_data[7]} ;

    reg [39:0] rx_data_reg = 0;
    reg rx_data_reg_valid = 0;

    // rx_data_reg
    always @ (posedge tick_i) begin
        if(rst_i)   
            rx_data_reg <= 0;

        else if(RX_stop_bit)
            rx_data_reg <= {RX_data_reversed, rx_data_reg[39:8]};
    end


    // state
    always @ (posedge tick_i) begin
        if(rst_i)begin
            state <= 0;
            out_o <= 0;
            done_o <= 0;
        end

        else if((state == 0) && rx_data_reg_valid) begin
            rx_data_reg_valid <= 0;
            out_o <= 0;
            done_o <= 0;
            state <= 1;
        end

        // generate checksum
        else if(state == 1) begin
            state <= 2;
        end

        else if((state == 2) & chk_out_valid) begin
            if(checksum_out == 0)
               error_o <= 0;
            else
                error_o <= 1;

            out_o <= rx_data_reg[39:16];
            done_o <= 1;
            state <= 0;
        end

    end

    assign chk_din = (state == 1) ? rx_data_reg : 0;
    assign chk_we = (state == 1);

endmodule