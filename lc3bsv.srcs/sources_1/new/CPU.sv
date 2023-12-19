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

`define opcode ir[15:12]
`define sr1 ir[8:6]
`define sr2 ir[2:0]

module CPU(clk, cs, we, address, bus);
    input clk;
    input cs;
    input we;
    output [15:0] address;
    inout [31:0] memory_bus;

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

    reg [15:0] ir, next_ir;
    reg [15:0] pc, next_pc;
    reg [15:0] mar, next_mar;
    reg [15:0] mdr, next_mdr;
    reg [15:0] ben, next_ben;
    reg [15:0] cc, next_cc;
    reg [15:0] n, next_n;
    reg [15:0] z, next_z;
    reg [15:0] p, next_p;
    reg [15:0] ready, next_ready;
    reg [15:0] state_number, next_state_number;
    wire [15:0] state_number_wire;
    reg [15:0] unlatched_mdr_value, unlatched_pc_value, unlatched_alu_value, unlatched_shf_value, unlatched_marmux_value, marmux_or_pcmux_adder, dest_register;
    wire [31:0] imm5_ext, pcoffset9_ext, pcoffset11_ext, boffset6_ext, alu_in_A, alu_in_B, reg_in, readreg1, readreg2, addr1mux_out, addr2mux_out, marmux_out, pcmux_out, shf_out, alu_out, mdr_out, bus_out;
    wire [31:0] bus;
    reg alu_or_mem, alu_or_mem_save, regw, writing, reg_or_imm, reg_or_imm_save;
    reg fetchDorI;
    wire [2:0] dr;
    reg [2:0] state, nstate;
    wire[1:0] instr_type = (`opcode == add) || (`opcode == and_intr) || (`opcode == xor_instr) ? 0 : 
            (`opcode == ldb) || (`opcode == ldw) || (`opcode == stb) || (`opcode == stw) ? 1 : 
            (`opcode == br) || (`opcode == jmp) || (`opcode == jsr) || (`opcode == jsrr) || (`opcode == lea) ? 2 : 
            (`opcode == shf) ? 3 : 4;
    integer i;
    wire [34:0] control_signals;
    
    //control signals from control store 
    controlstore CS(.state_number(state_number_wire), .control_signals(control_signals));
    wire ird, ldmar, ldmdr, ldir, ldben, ldreg, ldcc, ldpc, gatepc, gatemdr, gatealu, gatemarmux, gateshf, drmux, sr1mux, addr1mux, marmux, mioen, rw, datasize, lshf1;
    wire [5:0] j;
    wire [1:0] pcmux, addr2mux, aluk;
    assign ird = control_signals[ird];
    assign ldmar = control_signals[ld_mar];
    assign ldmdr = control_signals[ld_mdr];
    assign ldir = control_signals[ld_ir];
    assign ldben = control_signals[ld_ben];
    assign ldreg = control_signals[ld_reg];
    assign ldcc = control_signals[ld_cc];
    assign ldpc = control_signals[ld_pc];
    assign gatepc = control_signals[gate_pc];
    assign gatemdr = control_signals[gate_mdr];
    assign gatealu = control_signals[gate_alu];
    assign gatemarmux = control_signals[gate_marmux];
    assign gateshf = control_signals[gate_shf];
    assign drmux = control_signals[drmux];
    assign sr1mux = control_signals[sr1mux];
    assign addr1mux = control_signals[addr1mux];
    assign marmux = control_signals[marmux];
    assign mioen = control_signals[mio_en];
    assign rw = control_signals[r_w];
    assign datasize = control_signals[data_size];
    assign lshf1 = control_signals[lshf1];
    assign j[5:0] = {control_signals[j5], control_signals[j4], control_signals[j3], control_signals[j2], control_signals[j1], control_signals[j0]};
    assign pcmux = {control_signals[pcmux1], control_signals[pcmux0]};
    assign addr2mux = {control_signals[addr2mux1], control_signals[addr2mux0]};
    assign aluk = {control_signals[aluk1], control_signals[aluk0]};

    assign state_number_wire = state_number;
    assign imm5_ext = ir[4] ? {11'b11111111111, ir[4:0]} : {11'b00000000000, ir[4:0]};
    assign pcoffset9_ext = ir[8] ? {7'b1111111, ir[8:0]} : {7'b0000000, ir[8:0]};
    assign pcoffset11_ext = ir[10] ? {5'b11111, ir[10:0]} : {5'b00000, ir[10:0]};
    assign boffset6_ext = ir[5] ? {10'b1111111111, ir[5:0]} : {10'b0000000000, ir[5:0]};
    assign dr = ir[11:9];
    assign alu_in_A = readreg1;
    assign alu_in_B = reg_or_imm ? imm5_ext : readreg2;
    assign bus = (gate_pc) ? pc : 
            (gate_mdr) ? mdr : 
            (gate_alu) ? alu_out : 
            (gate_marmux) ? marmux_out : 
            (gate_shf) ? shf_out : 32'bZ;

    assign reg_input = bus;

    
endmodule
