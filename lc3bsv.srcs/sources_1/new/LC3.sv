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
wire [31:0] bus_contents;
wire slow_clk;

memory mem(.cs(cs), .we(we), .clk(clk), .address(address), .bus(bus_contents));
CPU littlecomputer3(.clk(clk), .cs(cs), .we(we), .address(address), .bus(bus_contents));

endmodule
