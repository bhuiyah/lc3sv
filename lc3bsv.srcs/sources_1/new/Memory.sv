`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2023 07:19:34 PM
// Design Name: 
// Module Name: memory
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

module memory(cs, we, clk, rw, address, memory_bus 
    `ifdef SIMULATE_CPU
        , r, start_pc, memory_initialized
    `endif
    );

    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address;
    inout [15:0] memory_bus;

    `ifdef SIMULATE_CPU
        output r;
        output [15:0] start_pc;
        output memory_initialized;
    `endif

    wire cache_miss;

    DRAM dram(.cs(cs), .we(we), .clk(clk), .rw(rw), .address(address), .memory_bus(memory_bus) 
        `ifdef SIMULATE_CPU
            , .r(r), .start_pc(start_pc), .memory_initialized(memory_initialized)
        `endif
        , .cache_miss(cache_miss)
    );
    
    SRAM sram(.cs(cs), .we(we), .clk(clk), .rw(rw), .address(address), .memory_bus(memory_bus) 
        `ifdef SIMULATE_CPU
            , .r(r), .memory_initialized(memory_initialized)
        `endif
        , .cache_miss(cache_miss)
    );

endmodule
