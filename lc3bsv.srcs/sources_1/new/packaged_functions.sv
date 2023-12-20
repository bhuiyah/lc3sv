`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2023 07:40:34 PM
// Design Name: 
// Module Name: packaged_functions
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


package packaged_functions;
    function automatic [15:0] sext(input [15:0] A, input [3:0] num_bits); 

        reg sign_bit;
        reg [15:0] mask;

        sign_bit = (A >> (num_bits - 1)) & 1;
        if(sign_bit) begin
            mask = {16'hFFFF << num_bits};
            sext = A | mask;
        end
        else begin
            sext = A;
        end
        return sext;
    endfunction
endpackage
