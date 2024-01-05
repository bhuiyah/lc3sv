`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2024 06:15:09 PM
// Design Name: 
// Module Name: interface
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


interface mem_intf(input logic clk, reset);
    logic cs;
    logic [1:0] we;
    logic rw;
    logic [15:0] address;
    logic [15:0] memory_bus;

    //driver clocking block
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output address;
        inout memory_bus;
        output cs;
        output we;
        output rw;
    endclocking

    //monitor clocking block
    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input address;
        input memory_bus;
        input cs;
        input we;
        input rw;
    endclocking

    //driver modport
    modport DRIVER(clocking driver_cb, input clk, reset);

    //monitor modport
    modport MONITOR(clocking monitor_cb, input clk, reset);


endinterface