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

    input cs; // chip select
    input[1:0] we; // write enable
    input clk;
    input rw; // read/write
    input [15:0] address; // address to read/write
    inout [15:0] memory_bus; //memory bus holding mem data and shared between sram and cpu

    `ifdef SIMULATE_CPU
        output [15:0] start_pc;
        output memory_initialized;
    `endif

    wire cache_hit;
    wire mem_en;
    wire r_cache;
    wire r_mem;
    wire [31:0] cache_line_bus; //will always hold 4 bytes and only sharerd between cache and memory

    assign r = r_cache; //when cache is ready, cache is updated and is ready to be read by cpu

    SRAM sram(.cs(cs), .we(we), .clk(clk), .rw(rw), .address(address), .memory_bus(memory_bus) 
    `ifdef SIMULATE_CPU
        , .r_cache(r_cache), .r_mem(r_mem)
    `endif
    , .cache_hit(cache_hit), .mem_en(mem_en), .cache_line_bus(cache_line_bus)
    );

    DRAM dram(.cs(cs), .we(we), .clk(clk), .rw(rw), .address(address), .cache_line_bus(cache_line_bus)
        `ifdef SIMULATE_CPU
            , .r_mem(r_mem), .start_pc(start_pc), .memory_initialized(memory_initialized)
        `endif
        , .cache_hit(cache_hit), .mem_en(mem_en)
    );

endmodule
