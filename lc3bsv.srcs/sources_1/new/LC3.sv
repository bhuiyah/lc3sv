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

module LC3(CLK);

input CLK;

wire cs;
wire [1:0] we;
wire [15:0] address;
wire [15:0] memory_bus;
wire [34:0] control_signals;
wire r;
wire [3:0] opcode;
wire ir11;
wire ben;
wire rw;
wire [15:0] start_pc;
wire memory_initialized;
wire [15:0] current_pc;

memory mem(.cs(cs), .we(we), .clk(clk), .rw(rw), .address(address), .memory_bus(memory_bus), .r(r), .start_pc(start_pc), .memory_initialized(memory_initialized));
datapath lc3(.clk(CLK), .cs(cs), .we(we), .address(address), .memory_bus(memory_bus), .control_signals(control_signals), .opcode(opcode), .ir11(ir11), .ben(ben), .rw(rw), .r(r), .start_pc(start_pc), .memory_initialized(memory_initialized), .pc(current_pc));
control cont(.clk(CLK), .r(r), .opcode(opcode), .ir11(ir11), .ben(ben), .control_signals(control_signals), .memory_initialized(memory_initialized), .current_pc(current_pc));

endmodule
