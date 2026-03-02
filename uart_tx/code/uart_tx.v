// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to generate UART Tx data packet to transmit the messages based on the input data.
Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.
Warning: The error due to compatibility will not be entertained.
-------------------
*/
/*
Module UART Transmitter
Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit
Output: tx      - UART Transmission Line
        tx_done - message transmitted flag
        Baudrate : 115200 bps
*/
// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

// Single 11-bit register to hold only control variables
// [10:8] = state (3 bits)
// [7:3]  = bit_counter (5 bits)
// [2:0]  = data_bit_index (3 bits)

reg [10:0] sr = 11'd0;

// Bit field assignments for readability
wire [2:0] state = sr[10:8];
wire [4:0] bit_counter = sr[7:3];
wire [2:0] data_bit_index = sr[2:0];

// State definitions
localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DATA   = 3'd2;
localparam PARITY = 3'd3;
localparam STOP   = 3'd4;

// Parity calculation (combinational, no storage needed)
wire parity_bit = (parity_type == 1'b0) ? (^data) : ~(^data);

// Combinational logic for tx output
always @(*) begin
    case(state)
        IDLE:    tx = 1'b1;
        START:   tx = 1'b0;
        DATA:    tx = data[7 - data_bit_index];
        PARITY:  tx = parity_bit;
        STOP:    tx = 1'b1;
        default: tx = 1'b1;
    endcase
end

// Main FSM
always @(posedge clk_3125) begin
    case(state)
        IDLE: begin
            tx_done <= 1'b0;
            
            if(tx_start) begin
                sr[10:8] <= START;            // state = START
                sr[7:3] <= 5'd0;              // bit_counter = 0
                sr[2:0] <= 3'd0;              // data_bit_index = 0
            end
        end
        
        START: begin
            tx_done <= 1'b0;
            
            if(bit_counter == 26) begin
                sr[10:8] <= DATA;             // state = DATA
                sr[7:3] <= 5'd0;              // bit_counter = 0
            end else begin
                sr[7:3] <= bit_counter + 1;
            end
        end
        
        DATA: begin
            tx_done <= 1'b0;
            
            if(bit_counter == 26) begin
                sr[7:3] <= 5'd0;              // bit_counter = 0
                if(data_bit_index == 7) begin
                    sr[2:0] <= 3'd0;          // data_bit_index = 0
                    sr[10:8] <= PARITY;       // state = PARITY
                end else begin
                    sr[2:0] <= data_bit_index + 1;
                end
            end else begin
                sr[7:3] <= bit_counter + 1;
            end
        end
        
        PARITY: begin
            tx_done <= 1'b0;
            
            if(bit_counter == 26) begin
                sr[7:3] <= 5'd0;              // bit_counter = 0
                sr[10:8] <= STOP;             // state = STOP
            end else begin
                sr[7:3] <= bit_counter + 1;
            end
        end
        
        STOP: begin
            if(bit_counter == 25) begin
                tx_done <= 1'b1;
            end else begin
                tx_done <= 1'b0;
            end
            
            if(bit_counter == 26) begin
                sr[7:3] <= 5'd0;              // bit_counter = 0
                sr[10:8] <= IDLE;             // state = IDLE
            end else begin
                sr[7:3] <= bit_counter + 1;
            end
        end
        
        default: begin
            sr[10:8] <= IDLE;
            tx_done <= 1'b0;
        end
    endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
endmodule