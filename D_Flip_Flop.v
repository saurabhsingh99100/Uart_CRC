module D_Flip_Flop(Q, D, Clk, rst);
    input D;
    input Clk;
    output reg Q;
    input rst;

    initial Q = 0;

    always @ (posedge Clk) begin
        if(rst == 1'b1)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule
