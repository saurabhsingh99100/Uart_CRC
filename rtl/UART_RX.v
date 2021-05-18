module UART_RX#(parameter N = 8)                            // N = packet size
    (
    /* PORTLIST */
    output reg [N-1:0]  data_o,
    output              rx_done,
                        stop_bit,

    
    input               rx_i,
                        rx_en_i,
                        tick_i, 
                        clk_i,
                        rst_i
    );

    parameter   IDLE    = 0,
                READING = 1; 
        
    initial     data_o  = 0;


    // Internal registers
    reg state   = IDLE;

    assign rx_done = ~state;

    /////////////////////// STATE Machine //////////////////////
    /*
        Controls state transitions
    */
    always @ (posedge clk_i) begin
        if(rst_i)
            state <= IDLE;
        else
            state <= next(rx_i, state, rx_en_i, stop_bit_cond);
    end

    /*
        Next state decision (combinational logic)
    */
    function next;
        input rx_i;
        input state;
        input rx_en_i;
        input stop_bit_cond;
        
        begin
            case(state)
                IDLE:       if(!rx_i & rx_en_i)     next = READING;     // first neg-edge
                            else                    next = IDLE;
                
                READING:    if(stop_bit_cond)       next = IDLE;
                            else                    next = READING;

                default:                            next = IDLE;
            endcase
        end
    endfunction 

    reg [3:0]           counter     = 0;
    reg [$clog2(N):0]    bitcount    = 0;

    /*
        rx_i        |``````````\......../````````\................/`````````\................/````````````````````````````````
                    |      |        |        |        |        |        |        |        |        |        |        |        |
                                start bit    D7       D6       D5       D4       D3       D2       D1       D0    stop bit
        
        bitcount    <      0        ><   1   ><   2   ><   3   ><   4   ><    5  ><   6   ><   7   ><   8   ><   9   ><   0   ><
    */

    wire start_bit_cond     = (counter == 7)    &   (bitcount == 0);
    wire data_bit_cond      = (counter == 15)   &   (bitcount <= N);
    wire stop_bit_cond      = (counter == 15)   &   (bitcount == N+1)    &    (rx_i);   

    assign stop_bit = stop_bit_cond;

    // counter
    always @ (posedge tick_i)begin
        if(state == READING) begin
            if(start_bit_cond | data_bit_cond)
                counter <= 0;

            else 
                counter <= counter +1;
        end
        if(stop_bit_cond)
                counter <= 0;        
    end

    // bitcount
    always @ (posedge tick_i)begin
        if(state == READING)begin
            if(start_bit_cond | data_bit_cond)
                bitcount <= bitcount+1;            
            
        end
        if(stop_bit_cond)
                bitcount <= 0;
    end

    // data_o
    always @ (posedge tick_i)begin
        if(state == READING)begin
            if(start_bit_cond)
                data_o <= 0;
            if(data_bit_cond)
                data_o <=  {data_o[6:0], rx_i};  //SAMPLING
        end
    end
    
endmodule