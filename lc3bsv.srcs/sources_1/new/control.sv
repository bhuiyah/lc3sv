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

`include "sign_extend.vh"
import sign_extend::*;

module control(clk, r, opcode, ir11, ben, control_signals, memory_initialized, current_pc);
    input clk;
    input r;
    input [3:0] opcode;
    input ir11;
    input ben;
    input memory_initialized;
    input [15:0] current_pc;
    
    output reg [25:0] control_signals;

    integer i;
    bit [5:0] state_number;
    bit [5:0] next_state_number;
    wire run_bit; 

    bit [34:0] control_store [63:0];

    bit  [5:0] j;
    bit  [1:0] cond;
    bit ird;

    assign run_bit = memory_initialized && (current_pc != 16'h0000);
    
    initial begin
        $readmemb("cs.mem", control_store);
        state_number = 18;
        control_signals = control_store[state_number][25:0];
    end

    always_latch begin
        //microsequencer
        if(run_bit) begin
            ird = control_store[state_number][34];
            cond = control_store[state_number][33:32];
            j = control_store[state_number][31:26];
            if(ird)
                next_state_number = {2'b00, opcode};
            else begin
                case(cond)
                    2'b00:
                        next_state_number = j;

                    2'b01:
                        next_state_number = j | ({5'b00000, r} << 1);

                    2'b10:
                        next_state_number = j | ({5'b00000, ben} << 2);

                    2'b11:
                        next_state_number = j | ({5'b00000, ir11});

                endcase
            end
        end
        else begin
            next_state_number = 18;
        end
    end

    always@(posedge clk) begin
        state_number = next_state_number;
        if(run_bit) begin
            control_signals = control_store[state_number][25:0];
        end
        else begin
            control_signals = 26'b0;
        end
    end

endmodule


