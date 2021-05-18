`include "D_Flip_Flop.v"
`default_nettype none

module checksum(
    input [39:0]data_i,
    input       we_i,
                clk_i,
                rst_i, 

    input [16:0] mask_i,

    output reg [15:0] out_o,
    output reg out_valid_o
);

    initial out_o = 0;
    initial out_valid_o = 0;
    
    reg [39:0] data = 0;
    reg [5:0] count = 0;
    reg valid = 0;

    wire rst_ff = !valid;

    wire serial_data = data[39];
    // data
    always @ (posedge clk_i)begin
        if(rst_i)
            data <= 0;
        else if (we_i)
            data <= data_i;
    end

    // valid
    always @ (posedge clk_i)begin
        if(rst_i)
            valid <= 0;
        else if (we_i)
            valid <= 1;
        else if (count == 41)
            valid <= 0;
    end

    // count
    always @ (posedge clk_i)begin
        if(rst_i | we_i)
            count <= 0;
        else if (we_i)
            count <= 1;
        else if(count == 41)
            count <= 0;
        else if(valid)
            count <= count+1;
    end
    
    // right shift each cycle
    always @ (posedge clk_i)begin
        if(valid & !we_i)begin
            data <= data << 1;
        end
     
    end

    wire done = count == 41;

    //out_o
    always @ (posedge clk_i)begin
        if(rst_i | we_i)
            out_o <= 0;
        else if(done)
            out_o <= Q;
    end

    //out_valid_o
    always @ (posedge clk_i)begin
        if(rst_i | we_i)
            out_valid_o <= 0;
        else if(done)
            out_valid_o <= 1;
    end
    



    wire [15:0]     D,
                    Q,
                    xout;

    wire            invert_en = Q[15];

    wire [15:0] invert = {16{invert_en}} & mask_i[15:0];


    assign xout[0] =  invert[0] ^ serial_data;
    assign xout[15:1] = invert[15:1] ^ Q[14:0];

    D_Flip_Flop d0(Q[0], xout[0], clk_i, rst_ff);
    D_Flip_Flop d1(Q[1], xout[1], clk_i, rst_ff);
    D_Flip_Flop d2(Q[2], xout[2], clk_i, rst_ff);
    D_Flip_Flop d3(Q[3], xout[3], clk_i, rst_ff);
    D_Flip_Flop d4(Q[4], xout[4], clk_i, rst_ff);
    D_Flip_Flop d5(Q[5], xout[5], clk_i, rst_ff);
    D_Flip_Flop d6(Q[6], xout[6], clk_i, rst_ff);
    D_Flip_Flop d7(Q[7], xout[7], clk_i, rst_ff);
    D_Flip_Flop d8(Q[8], xout[8], clk_i, rst_ff);
    D_Flip_Flop d9(Q[9], xout[9], clk_i, rst_ff);
    D_Flip_Flop d10(Q[10], xout[10], clk_i, rst_ff);
    D_Flip_Flop d11(Q[11], xout[11], clk_i, rst_ff);
    D_Flip_Flop d12(Q[12], xout[12], clk_i, rst_ff);
    D_Flip_Flop d13(Q[13], xout[13], clk_i, rst_ff);
    D_Flip_Flop d14(Q[14], xout[14], clk_i, rst_ff);
    D_Flip_Flop d15(Q[15], xout[15], clk_i, rst_ff);
endmodule