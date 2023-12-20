`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2023 04:45:14 PM
// Design Name: 
// Module Name: datapath
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

enum cs_bits {
    ird_idx,
    cond1_idx, cond0_idx,
    j5_idx, j4_idx, j3_idx, j2_idx, j1_idx, j0_idx,
    ld_mar_idx,
    ld_mdr_idx,
    ld_ir_idx,
    ld_ben_idx,
    ld_reg_idx,
    ld_cc_idx,
    ld_pc_idx,
    gate_pc_idx,
    gate_mdr_idx,
    gate_alu_idx,
    gate_marmux_idx,
    gate_shf_idx,
    pcmux1, pcmux0_idx,
    drmux_idx,
    sr1mux_idx,
    addr1mux_idx,
    addr2mux1_idx, addr2mux0_idx,
    marmux_idx,
    aluk1_idx, aluk0_idx,
    mio_en_idx,
    r_w_idx,
    data_size_idx,
    lshf1_idx,
    control_store_bits
} cs_bits;

module datapath(clk, cs, we, address, memory_bus, control_signals, r, opcode, ir11, ben);
    input clk;
    input [15:0] address;
    input [34:0] control_signals;

    inout [31:0] memory_bus;

    output reg cs, we;
    output reg r;
    output [3:0] opcode;
    output ir11;
    output reg ben;

    reg [15:0] instruction;

    wire ldreg = control_signals[ld_reg_idx];

    wire sr1 = instruction[8:6];
    wire sr2 = instruction[2:0];
    wire dr = instruction[11:9];

    assign opcode = instruction[15:12];

    wire [31:0] readreg1, readreg2;
    register_file reg_file(.clk(clk), .reg_write(ldreg), .DR(dr), .SR1(sr1), .SR2(sr2), .Reg_In(reg_input), .ReadReg1(readreg1), .ReadReg2(readreg2));
    
endmodule

module alu(clk, A, B, aluk, alu_out);
    input clk;
    input [15:0] A;
    input [15:0] B;
    input [1:0] aluk;
    output reg [15:0] alu_out;

    always @(posedge clk) begin
        case(aluk)
            2'b00: begin
                alu_out <= A & B;
            end
            2'b01: begin
                alu_out <= A + B;
            end
            2'b10: begin
                alu_out <= A ^ B;
            end
            2'b11: begin
                alu_out <= A;
            end
        endcase
    end
endmodule

module shf(clk, A, ir5_4, ammt4, shf_out);
    import packaged_functions::*;

    input clk;
    input [15:0] A;
    input [1:0] ir5_4;
    input [3:0] ammt4;
    output reg [15:0] shf_out;

    reg [15:0] A_sext;

    always @(posedge clk) begin
        case(ir5_4)
            2'b00: begin
                 shf_out <= (A << ammt4) && 16'hFFFF;
            end
            2'b01: begin
                shf_out <= (A >> ammt4) && 16'hFFFF;
            end
            2'b10: begin
                //will be skipped
                shf_out <= A;
            end
            2'b11: begin
                A_sext <= sext(A, 16);
                shf_out <= (A_sext >> ammt4) && 16'hFFFF;
            end
        endcase
    end
    
endmodule

module sr2mux(clk, sr2muxsignal, readreg2, imm5, sr2_out);
    input clk;
    input sr2muxsignal
    input [15:0] readreg2;
    input [4:0] imm5;
    output reg [15:0] sr2_out;

    always_ff @(posedge clk) begin
        sr2_out <= sr2muxsignal ? readreg2 : imm5;
    end

endmodule


