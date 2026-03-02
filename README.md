# UART
📌 Overview
This project implements a Universal Asynchronous Receiver and Transmitter (UART) protocol in Verilog HDL using Intel Quartus.
The design enables reliable asynchronous serial communication between digital systems using configurable baud rate generation and FSM-based control logic.

The system includes:

UART Transmitter (TX)
UART Receiver (RX)
Baud Rate Generator
Simulation testbench

⚙️Features

Configurable baud rate generation using clock divider
8-bit data frame format (1 Start bit, 8 Data bits, 1 Stop bit)
FSM-based TX and RX architecture
Mid-bit sampling for accurate data reception
Fully synthesizable design
Verified using simulation and timing analysis in Quartus

🔁 UART Transmitter (uart_tx)
Inputs

clk_3125
tx_start
data[7:0]
parity_type (0 = Even, 1 = Odd)

Outputs

tx
tx_done

Functionality

Generates Start bit
Serializes 8-bit data (LSB first)
Computes parity bit
Appends Stop bit
Asserts tx_done after frame completion

📥 UART Receiver (uart_rx)
Inputs

clk_3125
rx

Outputs

rx_msg[7:0]
rx_parity
rx_complete

Functionality

Detects Start bit (falling edge)
Performs timed sampling
Extracts data and parity
Validates parity
Outputs received message
Asserts rx_complete when done

If parity mismatch occurs:
Receiver outputs 8'h3F ('?') as error indication

🛠 Tools Used

Verilog HDL
Intel Quartus Prime
ModelSim Simulator
