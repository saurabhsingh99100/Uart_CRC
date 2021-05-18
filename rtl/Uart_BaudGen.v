//////////////////////////////////////////////////////////////////////////////////
// File:  Uart_BaudGen
//
// Description:  Generates 16 times oversampled tick signal for reciever and transmitter
//
//
//                                Inp_Clk_Freq(Hz)
// Formula =>       LIM = floor(----------------------)
//                                16 x BaudRate(Hz)
//
// FACTOR | BAUD    |   LIM @(12Mhz)
// -------------------------
// 0        1200        625
// 1        2400        312
// 2        4800        156
// 3        9600        78
// 4        19200       39
// 5        38400       19
// 6        57600       13
// 7        115200      6
//////////////////////////////////////////////////////////////////////////////////
module Uart_BaudGen(tick_o, Limit_i, clk_i, rst_i);

	input	clk_i,	
			rst_i;

	input	[15:0]	Limit_i; 		// Value to stop counter at
	output         	tick_o;			// Each "BaudRate" pulses we create a tick pulse


	reg [15:0]      counter; 		// Register used to count
	initial 		counter = 16'd0;

	// Counter Logic
	always @(posedge clk_i or posedge rst_i) begin
		 if (rst_i | (counter == Limit_i)) 
			counter <= 16'b1;
		 else 
			counter <= counter + 1'b1;
	end
	assign tick_o = (counter <= (Limit_i / 2));

endmodule

