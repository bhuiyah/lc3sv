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

    constraint c1 { address > 16'h0000; }
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

    //deep copy constructor
    function transaction deep_copy();
        transaction tr_deep_copy;
        tr_deep_copy = new();
        tr_deep_copy.cs = this.cs;
        tr_deep_copy.we = this.we;
        tr_deep_copy.rw = this.rw;
        tr_deep_copy.address = this.address;
        tr_deep_copy.memory_bus = this.memory_bus;
        return tr_deep_copy;
    endfunction

endclass
