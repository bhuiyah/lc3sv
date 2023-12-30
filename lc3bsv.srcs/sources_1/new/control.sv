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

`include "enum_and_func.vh"
import enum_and_pkg::*;

module control(clk, r, opcode, ir11, ben, control_signals, memory_initialized, current_pc);
    input clk;
    input r;
    input [3:0] opcode;
    input ir11;
    input ben;
    input memory_initialized;
    input [15:0] current_pc;
    
    output bit [34:0] control_signals;

    bit[5:0] i;
    bit [5:0] state_number;
    bit [5:0] next_state_number;
    wire run_bit; 

    bit [34:0] control_store [63:0];

    bit  [5:0] j;
    bit  [1:0] cond;
    bit ird;

    assign run_bit = memory_initialized && (current_pc != 16'h0000);

    initial begin
        $readmemb("ucode3.mem", control_store);
        state_number = 18;
    end

    always_latch begin
        //microsequencer
        if(memory_initialized) begin
            ird = control_store[state_number][ird_idx];
            cond = {control_store[state_number][cond1_idx], control_store[state_number][cond0_idx]};
            j = {control_store[state_number][j5_idx], control_store[state_number][j4_idx], control_store[state_number][j3_idx], control_store[state_number][j2_idx], control_store[state_number][j1_idx], control_store[state_number][j0_idx]};
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

    always_comb begin
        if(run_bit) begin
            
            // 1. first for loop lets arithmetic and logic occur

            for(i = pcmux1_idx; i < control_store_bits; i = i + 1)
                control_signals[i] = control_store[state_number][i];

            // 2. second for loop loads any value from arithmetic/logic to the bus

            for(i = gate_pc_idx; i < pcmux1_idx; i = i + 1)
                control_signals[i] = control_store[state_number][i];

            // 3. third for loop loads any value from the bus to a register in datapath

            for(i = ld_mar_idx; i < gate_pc_idx; i = i + 1)
                control_signals[i] = control_store[state_number][i];
        end
        else begin
            control_signals = 35'b0;
        end
    end

    always@(posedge clk) begin
        state_number <= next_state_number;
    end

endmodule


