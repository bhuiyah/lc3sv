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


module memory(cs, we, clk, address, bus);
    input cs;
    input we;
    input clk;
    input [16:0] address;
    inout [31:0] bus;

    reg [31:0] data_out;
    reg [15:0] DRAM [16'h8000][2];

    assign bus = ((cs == 0) || (we == 1)) ? 32'bZ : data_out;

    initial begin
        //$readmemh(); //will add with instructions, vectors, etc.
    end

    always @(negedge clk) begin
        //write to memory
        if ((cs == 1) && (we == 1)) begin 
            DRAM[address][0] <= bus[31:16];
            DRAM[address][1] <= bus[15:0];
        end
        //read from memory
        data_out <= {DRAM[address][0], DRAM[address][1]};
    end

endmodule
