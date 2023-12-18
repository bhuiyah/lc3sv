`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2023 06:35:16 PM
// Design Name: 
// Module Name: register_file
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


module register_file(clk, reg_write, DR, SR1, SR2, Reg_In, ReadReg1, ReadReg2);
    input clk;
    input reg_write;
    input [2:0] DR;
    input [2:0] SR1;
    input [2:0] SR2;
    input [15:0] Reg_In;
    output reg [15:0] ReadReg1;
    output reg [15:0] ReadReg2;

    reg [15:0] reg_file [7:0];
    
    initial begin
        reg_file[0] = 16'h0000;
        reg_file[1] = 16'h0000;
        reg_file[2] = 16'h0000;
        reg_file[3] = 16'h0000;
        reg_file[4] = 16'h0000;
        reg_file[5] = 16'h0000;
        reg_file[6] = 16'h0000;
        reg_file[7] = 16'h0000;
        ReadReg1 = 16'h0000;
        ReadReg2 = 16'h0000;
    end

    always @(posedge clk) begin
        if(reg_write == 1) begin
            reg_file[DR] <= Reg_In;
        end

        ReadReg1 <= reg_file[SR1];
        ReadReg2 <= reg_file[SR2];
    end

endmodule
