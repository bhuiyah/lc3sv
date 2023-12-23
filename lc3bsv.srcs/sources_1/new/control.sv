`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2023 04:44:58 PM
// Design Name: 
// Module Name: control
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


module control(clk, r, opcode, ir11, ben, state_number, next_state_number, control_signals);
    input clk;
    input r;
    input [3:0] opcode;
    input ir11;
    input ben;
    input [5:0] state_number;
    output reg [5:0] next_state_number;
    output reg [34:0] control_signals;

    bit [5:0] j;
    bit [1:0] cond;
    bit ird; 

    bit [34:0] control_store [63:0];

    initial begin
        $readmemh("ucode3.mem", control_store);
    end

    always@(posedge clk) begin
        //microsequencer
        control_signals = control_store[state_number];
        ird = control_store[state_number][34];
        cond = control_store[state_number][33:32];
        j = control_store[state_number][31:26];
        
        if(ird) begin
            next_state_number <= opcode;
        end
        else begin
            case(cond)
                2'b00: begin
                    next_state_number <= j;
                end
                2'b01: begin
                    next_state_number <= r ? (j | r << 1) : j;
                end 
                2'b10: begin
                    next_state_number <= ben ? (j | ben << 2) : j;
                end
                2'b11 : begin
                    next_state_number <= ir11 ? (j | ir11) : j;
                end
            endcase
        end
    end

endmodule
