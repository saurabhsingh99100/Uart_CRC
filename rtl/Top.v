`timescale 1ns/10ps
`include "UART_TX.v"
`include "UART_RX.v"

module Top;

    /* TX INTERFACE */
    reg clk_master;
    reg tick;
    wire chng;
    reg [3:0] tick_counter;
    
    reg  tx_en = 1;    
    reg rst_i = 0;

    wire tx_o;
    wire tx_done;

    reg [7:0] data_i;
    reg       data_we_i;


    UART_TX utx
    (
    /* PORTLIST */
    tx_o,
    tx_done,
    
    data_i,
    data_we_i,

    tx_en,
    tick, 
    clk_master,
    rst_i
    );



    
    wire [7:0] data_o;
    wire rx_done;
    reg rx_en = 1;


  UART_RX urx(
    //////////////////// PORTLIST ////////////////////    
    data_o,
    rx_done,
    
    tx_o,
    rx_en,
    tick, 
    clk_master,
    rst_i
    );
    
    
    initial begin
        clk_master = 0;tick = 0; tx_en = 0; data_i = 0; data_we_i = 0;
        tick_counter = 0;
        $dumpfile("out_top.vcd");
        $dumpvars(0, Top);
        
        #700;
        data_i = 8'b11011010;
        data_we_i = 1; #4
        data_we_i = 0;
        #100;
        tx_en = 1;

        #5000;
        tx_en = 0;
        #5000;

        data_i = 8'b00101101;
        data_we_i = 1; #4
        data_we_i = 0;
        #5000;
        tx_en = 1;

        #10000;
        

        #10000;
        $finish();
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