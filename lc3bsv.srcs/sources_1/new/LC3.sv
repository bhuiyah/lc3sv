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

`define SIMULATE_CPU

module LC3(CLK);

input CLK;

wire cs;
wire [1:0] we;
wire [15:0] address;
wire [15:0] memory_bus;
wire [25:0] control_signals;
wire r_cache;
wire r_mem;
wire [3:0] opcode;
wire ir11;
wire ben;
wire rw;
wire [15:0] start_pc;
wire memory_initialized;
wire [15:0] current_pc;

reg gate_en;
reg load_en;

memory mem(.cs(cs), .we(we), .clk(CLK), .rw(rw), .address(address), .memory_bus(memory_bus), .r_cache(r_cache), .r_mem(r_mem), .start_pc(start_pc), .memory_initialized(memory_initialized));
datapath lc3(.clk(CLK), .cs(cs), .we(we), .address(address), .memory_bus(memory_bus), .control_signals(control_signals), .opcode(opcode), .ir11(ir11), .ben(ben), .rw(rw), .r(r), .start_pc(start_pc), .memory_initialized(memory_initialized), .pc(current_pc), .gate_en(gate_en), .load_en(load_en));
control cont(.clk(CLK), .r(r), .opcode(opcode), .ir11(ir11), .ben(ben), .control_signals(control_signals), .memory_initialized(memory_initialized), .current_pc(current_pc));

//perform tasks from state 18
initial begin
    gate_en = 0;
    load_en = 0;
    #0.1;
    gate_en = 1;
    #0.1; 
    gate_en = 0;
    #0.1;
    load_en = 1;
end

//scheduler
always @(posedge CLK) begin
    gate_en = 0;
    load_en = 0;
    #0.1;
    gate_en = 1;
    #0.1; 
    gate_en = 0;
    #0.1;
    load_en = 1;
end

endmodule
