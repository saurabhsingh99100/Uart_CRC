module UART_TX#(parameter N = 8)                            // N = packet size
    (
    /* PORTLIST */
    output  reg         tx_o,
    output              tx_done,
    
    input   [N-1:0]     data_i,
    input               data_we_i,

    input               tx_en_i,
                        tick_i, 
                        clk_i,
                        rst_i
    );

    parameter   IDLE            = 0,
                TRANSMITTING    = 1; 

    initial             tx_o    = 1;
    
    assign tx_done = ~state;

    /*
        Input data is registered
    */
    reg     [N-1:0]     data = 0;
    always @(posedge clk_i) begin
        if(rst_i)
            data <= 0;
        else if(data_we_i)
            data <= data_i;
    end
    

    /*
        data_valid flag is used to indicate arrival 
        of fresh input data
    */
    reg data_valid = 0;
    always @(posedge clk_i) begin
        if(rst_i)
            data_valid <= 0;
        else if(data_we_i)
            data_valid <= 1;
        if(stop_bit_cond)
            data_valid <= 0;    // data_valid is cleared after successful transmission 
    end
    


    // state register
    reg state   = IDLE;


    /////////////////////// STATE Machine //////////////////////
    /*
        Controls state transitions
    */
    always @ (posedge clk_i) begin
        if(rst_i)
            state <= IDLE;
        else
            state <= next(state, tx_en_i, data_valid, stop_bit_cond);
    end

    /*
        Next state decision (combinational logic)
    */
    function next;
        input state;
        input tx_en_i;
        input data_valid;
        input stop_bit_cond;
        
        begin
            case(state)
                IDLE:           if(data_valid & tx_en_i)    next = TRANSMITTING;
                                else                        next = IDLE;
                
                TRANSMITTING:   if(stop_bit_cond)           next = IDLE;
                                else                        next = TRANSMITTING;

                default:                                    next = IDLE;
            endcase
        end
    endfunction 

    reg [4:0]           counter     = 0;
    reg [$clog2(N):0]   bitcount    = 0;

    /*
        rx_i        |``````````````\......../````````\................/`````````\................/````````````````````````````````
                    |      |        |        |        |        |        |        |        |        |        |        |        |
                                start bit    D7       D6       D5       D4       D3       D2       D1       D0    stop bit
        
        bitcount    <      0        ><   1   ><   2   ><   3   ><   4   ><    5  ><   6   ><   7   ><   8   ><   9   ><   0   ><
    */

    wire start_bit_cond     = (counter == 1)   &   (bitcount == 0);
    wire data_bit_cond      = (counter == 15)   &   (bitcount <= N);
    wire stop_bit_cond      = (counter == 15)   &   (bitcount == N+1);   



    // counter
    always @ (posedge tick_i)begin
        if(state == TRANSMITTING) begin
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
        if(state == TRANSMITTING)begin
            if(start_bit_cond | data_bit_cond)
                bitcount <= bitcount+1;            
            
        end
        if(stop_bit_cond)
                bitcount <= 0;
    end

    // data
    always @ (posedge tick_i)begin
        if(state == TRANSMITTING)begin
            if(data_bit_cond)
                data <=  (data << 1);  // Shift data register
        end
        if(stop_bit_cond)
                data <= 0;
    end

    // tx_o
    always @ (posedge tick_i)begin
        if(state == TRANSMITTING)begin
            if(start_bit_cond)
                tx_o <= 0;
            if(data_bit_cond)
                tx_o <= data[N-1];      
        end
        if(stop_bit_cond)
                tx_o <= 1;              
    end


endmodule