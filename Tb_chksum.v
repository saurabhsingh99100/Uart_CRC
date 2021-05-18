`timescale 1ns/10ps

`default_nettype none

`include "checksum.v"

module Top;
    
    reg [39:0] data_i;
    reg       we_i,
                clk_i=0,
                rst_i; 

    reg [16:0] mask_i;

    wire [15:0] out_o;
    wire out_valid_o;
    
    checksum ck(
        data_i,
        we_i,
        clk_i,
        rst_i, 

        mask_i,

        out_o,
        out_valid_o
    );


    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, Top);

        mask_i = 17'b10001000000100001;
        rst_i=0;
        data_i = {"Hi!", 16'b0011000111111101};
        we_i=0; #2;
        we_i = 1;#2;
        we_i=0; #200;

        data_i = "Hi!\0\0";
        we_i=0; #2;
        we_i = 1;#2;
        we_i=0; #100;
        $finish();

        
        
    end
    // master clk
    always begin
        #1;
        clk_i <= ~clk_i;
    end
    
endmodule