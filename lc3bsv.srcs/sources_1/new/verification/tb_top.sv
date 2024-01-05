`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2024 12:21:52 AM
// Design Name: 
// Module Name: tb_top
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
`include "interface.sv"
`include "test1.sv"

module tb_top;

    bit clk;
    bit reset;

    //clock generation
    always begin
        #0.5 clk = ~clk;
    end

    //reset generation
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    //creating instance of interface to connect DUT and testcases
    mem_intf intf(clk, reset);

    //testcase instance, interface handle is passed to test as an arguement
    firsttest t1(intf);

    //DUT instance, interface signals are connected to the DUT ports
    memory mem(.cs(intf.cs), .we(intf.we), .clk(clk), .rw(intf.rw), .address(intf.address), .memory_bus(intf.memory_bus));

    //enabling wave dump
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule
