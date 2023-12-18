`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2023 07:02:58 PM
// Design Name: 
// Module Name: CPU
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
    ird,
    cond1, cond0,
    j5, j4, j3, j2, j1, j0,
    ld_mar,
    ld_mdr,
    ld_ir,
    ld_ben,
    ld_reg,
    ld_cc,
    ld_pc,
    gate_pc,
    gate_mdr,
    gate_alu,
    gate_marmux,
    gate_shf,
    pcmux1, pcmux0,
    drmux,
    sr1mux,
    addr1mux,
    addr2mux1, addr2mux0,
    marmux,
    aluk1, aluk0,
    mio_en,
    r_w,
    data_size,
    lshf1,
    control_store_bits
} cs_bits;

typedef struct {
    integer pc, mdr, mar, ir, ben, cc, n, z, p, ben, ready;
    integer microinstruction[control_store_bits];
    integer state_number;
} System_Latches;

System_Latches current_latches, next_latches;

module CPU(clk, cs, we, address, bus);
    input clk;
    input cs;
    input we;
    output [15:0] address;
    inout [31:0] bus;

    parameter add = 4'b0001;
    parameter and_intr = 4'b0101;
    parameter br = 4'b0000;
    parameter jmp = 4'b1100;
    parameter jsr = 4'b0100;
    parameter jsrr = 4'b0100;
    parameter ldb = 4'b0010;
    parameter ldw = 4'b0110;
    parameter lea = 4'b1110;
    parameter not_instr = 4'b1001;
    parameter ret = 4'b1100;
    parameter rti = 4'b1000;
    parameter shf = 4'b1101;
    parameter stb = 4'b0011;
    parameter stw = 4'b0111;
    parameter trap = 4'b1111;
    parameter xor_instr = 4'b1001;

    reg [3:0] opcode;
    
endmodule
