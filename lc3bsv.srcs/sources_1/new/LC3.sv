`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2023 06:46:08 PM
// Design Name: 
// Module Name: LC3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LC3(input CLK);

wire cs, we;
wire [15:0] address;
wire [31:0] memory_bus;
wire [34:0] control_signals;
wire r;
wire [3:0] opcode;
wire ir11;
wire ben;
wire slow_clk;

memory mem(.cs(cs), .we(we), .clk(clk), .address(address), .memory_bus(memory_bus));
datapath lc3(.clk(clk), .cs(cs), .we(we), .address(address), .memory_bus(memory_bus), .control_signals(control_signals), .r(r), .opcode(opcode), .ir11(ir11), .ben(ben));
control cont(.clk(clk), .r(r), .opcode(opcode), .ir11(ir11), .ben(ben), .state_number(state_number), .next_state_number(next_state_number), .control_signals(control_signals));

endmodule
