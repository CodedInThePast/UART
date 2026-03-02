module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );
initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
/* Add your logic here */

// State definitions
localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DATA   = 3'd2;
localparam PARITY = 3'd3;
localparam STOP   = 3'd4;

// Internal registers
reg [2:0] state = IDLE;
reg [4:0] bit_counter = 0;      // Counter for 27 clocks per bit
reg [2:0] data_bit_index = 0;   // Counter for 8 data bits (0 to 7)
reg [7:0] data_temp = 0;        // Temporary register to hold received data
reg parity_temp = 0;            // Temporary register to hold received parity
reg [2:0] c_count=0;

// Main FSM
always @(posedge clk_3125) begin
    case(state)
        IDLE: begin
            rx_complete <= 1'b0;
            bit_counter <= 0;
            data_bit_index <= 0;
            data_temp <= 0;
            parity_temp <= 0;
            
            // Detect start bit (rx goes low)
            if(rx == 1'b0) begin
                state <= START;
					 if(c_count == 1'b0) begin
					 bit_counter <= 0;
					 end else begin
					 bit_counter <=1;
					 end
            end
        end
        
        START: begin
            rx_complete <= 1'b0;
            
            // Sample at middle of bit period (clock 13)
            if(bit_counter == 13) begin
                // Verify it's still a valid start bit
                if(rx == 1'b0) begin
                    // Continue to data state
                end
            end
            
            if(bit_counter == 26) begin
                bit_counter <= 0;
                state <= DATA;
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end
        
        DATA: begin
            rx_complete <= 1'b0;
            
            // Sample at middle of bit period (clock 13)
            if(bit_counter == 13) begin
                // Receive LSB first, store in reversed order
                data_temp[7-data_bit_index] <= rx;
            end
            
            if(bit_counter == 26) begin
                bit_counter <= 0;
                if(data_bit_index == 7) begin
                    data_bit_index <= 0;
                    state <= PARITY;
                end else begin
                    data_bit_index <= data_bit_index + 1;
                end
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end
        
        PARITY: begin
				rx_complete <= 1'b0;
    
						// Sample parity bit at middle of bit period (clock 13)
					 if(bit_counter == 13) begin
						  parity_temp <= rx;
					 end
					 
					 if(bit_counter == 26) begin
						  bit_counter <= 0;
						  state <= STOP;
						  // Calculate expected parity (XOR of all data bits for even parity)
						  //rx_parity <= ^data_temp;  // <-- Add this line
					 end else begin
						  bit_counter <= bit_counter + 1;
					 end
				end
        
					STOP: begin
     // Sample at middle of bit period and prepare outputs
     if(bit_counter == 26) begin
                rx_msg <= data_temp;
                rx_parity <= ^data_temp;
					 bit_counter <= 0;
					 state <= IDLE;
					 if(rx == 1'b1 | rx_msg!=8'b00000000)begin
                rx_complete <= 1'b1;
					 end else begin
					 rx_complete <= 1'b0;
					 end
                c_count <= c_count + 1'b1;
            end else begin
                rx_complete <= 1'b0;
					 bit_counter <= bit_counter + 1;
            end
     
     // Complete the stop bit period and transition to IDLE
  
end
    endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
endmodule