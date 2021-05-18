`timescale 1ns/10ps
`include "UART_RX.v"

module Uart_Rx_tb;
    reg clk_master;
    reg tick;
    
    wire chng;
    
    reg [3:0] tick_counter;
    reg rx_i;
    
    wire [7:0] data_o;
    wire rx_done;
    reg rx_en = 1;

    wire rst_i = 0;

  UART_RX urx(
    //////////////////// PORTLIST ////////////////////    
    data_o,
    rx_done,
    
    rx_i,
    rx_en,
    tick, 
    clk_master,
    rst_i
    );

    initial begin
        clk_master = 0;tick = 0; rx_en = 1;
        tick_counter = 0; rx_i = 1;
        $dumpfile("out_rx.vcd");
        $dumpvars(0, Uart_Rx_tb);
        #40000;
        $finish();
    end

    
    reg [7:0] ct = 0;
    always @(posedge chng) begin
        ct <= ct+1;
    end

    always @(posedge chng) begin
        case(ct)

        //test case 1
        2: rx_i<=0;

        3: rx_i<=1;
        4: rx_i<=1;
        5: rx_i<=0;
        6: rx_i<=0;

        7: rx_i<=1;
        8: rx_i<=0;
        9: rx_i<=1;
        10: rx_i<=1;


        //test case 2
        16: rx_i<=0;

        17:rx_i <= 0;
        18:rx_i <= 1;
        19:rx_i <= 0;
        20:rx_i <= 0; 
        
        21:rx_i <= 0;
        22:rx_i <= 1;
        23:rx_i <= 1;
        24:rx_i <= 1;


        //test case 3
        29: rx_i<=0;

        30:rx_i <= 1;
        31:rx_i <= 1;
        32:rx_i <= 0;
        33:rx_i <= 1;
        
        34:rx_i <= 0;
        35:rx_i <= 1;
        36:rx_i <= 0;
        37:rx_i <= 1;



        //test case 4
        45: rx_i<=0;

        46:rx_i <= 0;
        47:rx_i <= 1;
        48:rx_i <= 0;
        49:rx_i <= 1;
        
        50:rx_i <= 0;
        51:rx_i <= 0;
        52:rx_i <= 0;
        53:rx_i <= 1;



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