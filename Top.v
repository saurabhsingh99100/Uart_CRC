`timescale 1ns/10ps

`default_nettype none

`include "rtl/UART_RX.v"
`include "CRC_Rx_Engine.v"
`include "checksum.v"

module Top;
    reg clk_master;
    reg tick;
    
    wire chng;
    
    reg [3:0] tick_counter;
    reg rx_i;
    
    wire [23:0] data_o;
    wire error;
    wire rx_done;
    reg rx_en = 1;

    wire rst_i = 0;

        
    CRC_Rx_Engine crc_rx
    (
        .rx_i(rx_i), 
        .rx_en_i(rx_en),
        .clk_i(clk_master),
        .tick_i(tick),
        .rst_i(rst_i),

        .out_o(data_o), 
        .error_o(error)
    );

    initial begin
        clk_master = 0;tick = 0; rx_en = 1;
        tick_counter = 0; rx_i = 1;
        $dumpfile("out_crc_rx.vcd");
        $dumpvars(0, Top);
        #60000;
        $finish();
    end

    
    reg [7:0] ct = 0;
    always @(posedge chng) begin
        ct <= ct+1;
    end

    reg [39:0] data = {"Hi!", 16'b0011000111111101};
    reg [7:0] i = 0;

    always @(posedge chng) begin
        
        case(ct)

        // PACKET 1
        2: rx_i <= 0;

        3: begin rx_i  <= data[i]; i <= i+1; end
        4: begin rx_i  <= data[i]; i <= i+1; end
        5: begin rx_i  <= data[i]; i <= i+1; end
        6: begin rx_i  <= data[i]; i <= i+1; end
        7: begin rx_i  <= data[i]; i <= i+1; end
        8: begin rx_i  <= data[i]; i <= i+1; end
        9: begin rx_i  <= data[i]; i <= i+1; end
        10: begin rx_i  <= data[i]; i <= i+1; end


        // PACKET 2
        16: rx_i <= 0;

        17:begin rx_i  <= data[i]; i <= i+1; end
        18:begin rx_i  <= data[i]; i <= i+1; end
        19:begin rx_i  <= data[i]; i <= i+1; end
        20:begin rx_i  <= data[i]; i <= i+1; end
        21:begin rx_i  <= data[i]; i <= i+1; end
        22:begin rx_i  <= data[i]; i <= i+1; end
        23:begin rx_i  <= data[i]; i <= i+1; end
        24:begin rx_i  <= data[i]; i <= i+1; end

        // PACKET 3
        29: rx_i<=0;

        30:begin rx_i  <= data[i]; i <= i+1; end
        31:begin rx_i  <= data[i]; i <= i+1; end
        32:begin rx_i  <= data[i]; i <= i+1; end
        33:begin rx_i  <= data[i]; i <= i+1; end
        34:begin rx_i  <= data[i]; i <= i+1; end
        35:begin rx_i  <= data[i]; i <= i+1; end
        36:begin rx_i  <= data[i]; i <= i+1; end
        37:begin rx_i  <= data[i]; i <= i+1; end

        // PACKET 4 (CHECKSUM)
        45: rx_i<=0;

        46:begin rx_i  <= data[i]; i <= i+1; end
        47:begin rx_i  <= data[i]; i <= i+1; end
        48:begin rx_i  <= data[i]; i <= i+1; end
        49:begin rx_i  <= data[i]; i <= i+1; end
        50:begin rx_i  <= data[i]; i <= i+1; end
        51:begin rx_i  <= data[i]; i <= i+1; end
        52:begin rx_i  <= data[i]; i <= i+1; end
        53:begin rx_i  <= data[i]; i <= i+1; end

        // PACKET 5 (CHECKSUM)
        59: rx_i<=0;

        60:begin rx_i  <= data[i]; i <= i+1; end
        61:begin rx_i  <= data[i]; i <= i+1; end
        62:begin rx_i  <= data[i]; i <= i+1; end
        63:begin rx_i  <= data[i]; i <= i+1; end
        64:begin rx_i  <= data[i]; i <= i+1; end
        65:begin rx_i  <= data[i]; i <= i+1; end
        66:begin rx_i  <= data[i]; i <= i+1; end
        67:begin rx_i  <= data[i]; i <= i+1; end

        default: rx_i<=1;

    endcase
    end








    // change
    always@(posedge tick) begin
        tick_counter <= tick_counter+1;
    end

    assign chng = (tick_counter == 15);

    
    
    
    // tick
    reg [2:0] clk_counter = 0;

    always@(posedge clk_master) begin
        clk_counter <= clk_counter+1;
    end
    wire ctr_chng = (clk_counter == 3);

    always@(posedge ctr_chng) begin
        tick <= ~tick;
    end



    // master clk
    always begin
        #1;
        clk_master <= ~clk_master;
    end
    
endmodule