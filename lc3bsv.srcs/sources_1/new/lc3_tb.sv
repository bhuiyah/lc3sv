`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2023 11:05:08 PM
// Design Name: 
// Module Name: lc3_tb
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


module lc3_tb;

    reg clk = 0;

    always #5 clk = ~clk;

    LC3 lc3(.CLK(clk));

endmodule
