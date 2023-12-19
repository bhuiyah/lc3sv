`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2023 07:30:52 PM
// Design Name: 
// Module Name: controlstore
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


module controlstore(
        input [15:0] state_number,
        output [34:0] control_signals
    );

    reg [34:0] control_store [63:0];

    initial begin
        readmemh("ucode.mem", control_store);
    end

    assign control_signals = control_store[state_number];

endmodule
