`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2024 02:31:37 AM
// Design Name: 
// Module Name: 
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

class transaction;

    rand bit cs;
    rand bit [1:0] we;
    rand bit rw;
    rand bit [15:0] address;
    rand bit [15:0] memory_bus;

    bit r;
    bit [15:0] start_pc;
    bit memory_initialized;

    constraint c1 { address >= 16'h0000; }
    constraint c2 { address <= 16'h7FFF; }

    // post_randomize() is called after randomization is complete
    function void post_randomize(); 
        $display("------- [Transaction] post_randomize -------");
        $display("cs = %b", cs);
        $display("we = %b", we);
        $display("rw = %b", rw);
        $display("address = %h", address);
        $display("memory_bus = %h", memory_bus);
        $display("--------------------------------------------");
    endfunction

endclass
