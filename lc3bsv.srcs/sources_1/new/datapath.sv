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

typedef enum bit[5:0] {
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
    pcmux1_idx, pcmux0_idx,
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

package packaged_functions;
    function automatic [15:0] sext(input [15:0] A, input [4:0] num_bits); 

        reg sign_bit;
        reg [15:0] mask;

        sign_bit = A[num_bits - 1] && 1;
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

import packaged_functions::*;

module datapath(clk, cs, we, address, memory_bus, control_signals, opcode, ir11, ben, rw, r);
    input clk;
    input [34:0] control_signals;
    input r;

    inout [15:0] memory_bus;

    output cs;
    output [1:0] we;
    output [15:0] address;
    output [3:0] opcode;
    output ir11;
    output ben;
    output rw;

    //control signals from control store
    bit ldreg = control_signals[ld_reg_idx];
    bit ldmar = control_signals[ld_mar_idx];
    bit ldmdr = control_signals[ld_mdr_idx];
    bit ldpc = control_signals[ld_pc_idx];
    bit ldcc = control_signals[ld_cc_idx];
    bit ldben = control_signals[ld_ben_idx];
    bit ldir = control_signals[ld_ir_idx];
    bit gatepc = control_signals[gate_pc_idx];
    bit gatemdr = control_signals[gate_mdr_idx];
    bit gatealu = control_signals[gate_alu_idx];
    bit gatemarmux = control_signals[gate_marmux_idx];
    bit gateshf = control_signals[gate_shf_idx];
    bit [1:0] pcmux = {control_signals[pcmux1_idx], control_signals[pcmux0_idx]};
    bit [1:0] addr2mux = {control_signals[addr2mux1_idx], control_signals[addr2mux0_idx]};
    bit [1:0] aluk = {control_signals[aluk1_idx], control_signals[aluk0_idx]};
    bit lshf1 = control_signals[lshf1_idx];
    bit drmux = control_signals[drmux_idx];
    bit sr1mux = control_signals[sr1mux_idx];
    bit addr1mux = control_signals[addr1mux_idx];
    bit marmux = control_signals[marmux_idx];
    bit data_size = control_signals[data_size_idx];
    bit mio_en = control_signals[mio_en_idx];
    
    wire [15:0] instruction;
    wire [2:0] sr1 = sr1mux ? instruction[8:6] : instruction[11:9];
    wire [2:0] sr2 = instruction[2:0];
    wire [2:0] dr = drmux ? 3'b111 : instruction[11:9];
    wire [15:0] readreg1, readreg2;
    wire [15:0] alu_out, shf_out, mdr_out, pc_out, marmux_out;
    wire [15:0] bus_contents;
    wire [15:0] A, B;
    wire [15:0] pc, mar, mdr;
    wire [2:0] cc;
    wire [15:0] addr1_out, addr2_out, lshf1_out, adder_out;
    wire [15:0] mdr_in_mioen_mux;
    wire [15:0] mioen_out;
    wire [15:0] mdr_val_from_mem;
    wire [1:0] we_out;

    assign opcode = instruction[15:12];
    assign cs = mio_en;
    assign we = we_out;
    assign rw = control_signals[r_w_idx];
    assign ir11 = instruction[11];
    assign mdr_val_from_mem = (mio_en && !rw && r) ? memory_bus : 16'h0000;
    assign A = readreg1;
    assign address = mar;

    //wiring the datapath
    register_file reg_file(.clk(clk), .reg_write(ldreg), .DR(dr), .SR1(sr1), .SR2(sr2), .Reg_In(bus_contents), .ReadReg1(readreg1), .ReadReg2(readreg2));
    bus b_u_s(.clk(clk), .alu_out(alu_out), .shf_out(shf_out), .mdr_out(mdr_out), .pc_out(pc_out), .marmux_out(marmux_out), .gatealu(gatealu), .gateshf(gateshf), .gatemdr(gatemdr), .gatepc(gatepc), .gatemarmux(gatemarmux), .bus_contents(bus_contents));
    sr2_mux sr2_mux(.clk(clk), .sr2muxsignal(instruction[5]), .readreg2(readreg2), .imm5(instruction[4:0]), .sr2_out(B));
    alu a_l_u(.clk(clk), .A(A), .B(B), .aluk(aluk), .alu_out(alu_out));
    shf s_h_f(.clk(clk), .A(A), .ir5_4(instruction[5:4]), .ammt4(instruction[3:0]), .shf_out(shf_out));
    addr1_mux addr1_mx(.clk(clk), .addr1mux(addr1mux), .pc(pc), .readreg1(readreg1), .addr1_out(addr1_out));
    addr2_mux addr2_mx(.clk(clk), .addr2mux(addr2mux), .ir(instruction), .addr2_out(addr2_out));
    lshf1mod lshf(.clk(clk), .lshf1(lshf1), .in(addr2_out), .lshf1_out(lshf1_out));
    adder_for_marmux_or_pcmux adder(.clk(clk), .lshf1_in(lshf1_out), .addr1mux_in(addr1_out), .adder_out(adder_out));
    mar_mux mar_mx(.clk(clk), .marmux(marmux), .adder_out(adder_out), .ir(instruction), .marmux_out(marmux_out));
    pc_mux pc_mx(.clk(clk), .pcmux(pcmux), .adder_out(adder_out), .bus(bus_contents), .pc(pc), .pcmux_out(pc_out));

    //loading registers
    ir_reg ir_r(.clk(clk), .ld_ir(ldir), .bus(bus_contents), .ir(instruction));
    ben_reg ben_r(.clk(clk), .ldben(ldben), .ir(instruction), .cc(cc), .ben(ben));
    cc_reg cc_r(.clk(clk), .ldcc(ldcc), .bus(bus_contents), .cc(cc));
    pc_reg pc_r(.clk(clk), .ldpc(ldpc), .pcmux_out(pc_out), .pc(pc));
    mar_reg mar_r(.clk(clk), .ldmar(ldmar), .bus(bus_contents), .mar(mar));
    mdr_reg mdr_r(.clk(clk), .ldmdr(ldmdr), .mioen_out(mioen_out), .mdr(mdr));

    //memory management
    mdr_in_logic mdr_in(.clk(clk), .bus(bus_contents), .data_size(data_size), .mdr_in_mioen_mux(mdr_in_mioen_mux));
    mio_en_mux mio_en_mx(.clk(clk), .mio_en(mio_en), .mdr_in_mioen_mux(mdr_in_mioen_mux), .mdr_val_from_mem(mdr_val_from_mem), .mioen_out(mioen_out));
    mdr_out_logic mdr_out_log(.clk(clk), .mdr(mdr), .data_size(data_size), .mar0(mar[0]), .mdr_out(mdr_out));
    we_logic we_l(.clk(clk), .rw(rw), .mar0(mar[0]), .data_size(data_size), .we_out(we_out));

endmodule

module bus(clk, alu_out, shf_out, mdr_out, pc_out, marmux_out, gatealu, gateshf, gatemdr, gatepc, gatemarmux, bus_contents);
    input clk;
    input [15:0] alu_out;
    input [15:0] shf_out;
    input [15:0] mdr_out;
    input [15:0] pc_out;
    input [15:0] marmux_out;
    input bit gatealu, gateshf, gatemdr, gatepc, gatemarmux;
    output reg [15:0] bus_contents;

    always@(posedge clk) begin
        if(gatealu) begin
            bus_contents <= alu_out;
        end
        else if(gateshf) begin
            bus_contents <= shf_out;
        end
        else if(gatemdr) begin
            bus_contents <= mdr_out;
        end
        else if(gatepc) begin
            bus_contents <= pc_out;
        end
        else if(gatemarmux) begin
            bus_contents <= marmux_out;
        end
        else begin
            bus_contents <= 16'h0000;
        end
    end
endmodule

module alu(clk, A, B, aluk, alu_out);
    input clk;
    input [15:0] A;
    input [15:0] B;
    input bit [1:0] aluk;
    output reg [15:0] alu_out;

    always_comb begin
        case(aluk)
            2'b00: begin
                alu_out = A & B;
            end
            2'b01: begin
                alu_out = A + B;
            end
            2'b10: begin
                alu_out = A ^ B;
            end
            2'b11: begin
                alu_out = A;
            end
        endcase
    end
endmodule

module shf(clk, A, ir5_4, ammt4, shf_out);
    // import packaged_functions::*;

    input clk;
    input [15:0] A;
    input [1:0] ir5_4;
    input [3:0] ammt4;
    output reg [15:0] shf_out;

    reg [15:0] A_sext;

    always_comb begin
        A_sext = sext(A, 16);
        case(ir5_4)
            2'b00: begin
                shf_out = (A << ammt4) & 16'hFFFF;
            end
            2'b01: begin
                shf_out = (A >> ammt4) & 16'hFFFF;
            end
            2'b10: begin
                //will be skipped
                shf_out = A;
            end
            2'b11: begin
                shf_out = (A_sext >> ammt4) & 16'hFFFF;
            end
            default: begin
                shf_out = A;
            end
        endcase
    end
    
endmodule

module sr2_mux(clk, sr2muxsignal, readreg2, imm5, sr2_out);
    // import packaged_functions::*;
    input clk;
    input bit sr2muxsignal;
    input [15:0] readreg2;
    input [4:0] imm5;
    output reg [15:0] sr2_out;

    always_comb begin
        sr2_out = sr2muxsignal ? sext({11'h000, imm5}, 5) : readreg2;
    end

endmodule

module addr1_mux(clk, addr1mux, pc, readreg1, addr1_out);
    input clk;
    input addr1mux;
    input [15:0] pc;
    input [15:0] readreg1;
    output reg [15:0] addr1_out;

    always_comb begin
        addr1_out = addr1mux ? readreg1 : pc;
    end
endmodule

module addr2_mux(clk, addr2mux, ir, addr2_out);
    // import packaged_functions::*;
    input clk;
    input [1:0] addr2mux;
    input [15:0] ir;
    output reg [15:0] addr2_out;

    always_comb begin
        case(addr2mux)
            2'b00: begin
                addr2_out = 16'h0000;
            end
            2'b01: begin
                //ir[5:0] is sexted to 16 bits
                addr2_out = sext({10'h000, ir[5:0]}, 6);
            end
            2'b10: begin
                addr2_out = sext({7'h00, ir[8:0]}, 9);
            end
            2'b11: begin
                addr2_out = sext({5'h00, ir[10:0]}, 11);
            end
        endcase
    end
endmodule

module lshf1mod(clk, lshf1, in, lshf1_out);
    input clk;
    input lshf1;
    input [15:0] in;
    output reg [15:0] lshf1_out;

    always_ff @(posedge clk) begin
        lshf1_out <= lshf1 ? (in << 1) : in;
    end
endmodule

module adder_for_marmux_or_pcmux(clk, lshf1_in, addr1mux_in, adder_out);
    input clk;
    input [15:0] lshf1_in;
    input [15:0] addr1mux_in;
    output reg [15:0] adder_out;

    always_comb begin
        adder_out = lshf1_in + addr1mux_in;
    end

endmodule

module mar_mux(clk, marmux, adder_out, ir, marmux_out);
    input clk;
    input marmux;
    input [15:0] adder_out;
    input [15:0] ir;
    output reg [15:0] marmux_out;

    always_comb begin
        marmux_out = marmux ? adder_out : (ir & 16'h00FF) << 1;
    end
endmodule

module pc_mux(clk, pcmux, adder_out, bus, pc, pcmux_out);
    input clk;
    input [1:0] pcmux;
    input [15:0] adder_out;
    input [15:0] bus;
    input [15:0] pc;
    output reg [15:0] pcmux_out;

    always_comb begin
        case(pcmux)
            2'b00: begin
                pcmux_out = pc + 2;
            end
            2'b01: begin
                pcmux_out = bus[15:0];
            end
            2'b10: begin
                pcmux_out = adder_out;
            end
            default: begin
                pcmux_out = pc;
            end
        endcase
    end
endmodule

//////////loading registers//////////
module ir_reg(clk, ld_ir, bus, ir);
    input clk;
    input ld_ir;
    input [15:0] bus;
    output reg [15:0] ir;

    always_ff @(posedge clk) begin
        if(ld_ir) begin
            ir <= bus[15:0];
        end
    end
endmodule

module ben_reg(clk, ldben, ir, cc, ben);
    input clk;
    input ldben;
    input [15:0] ir;
    input [2:0] cc;
    output reg ben;

    wire curr_n = cc[2];
    wire curr_z = cc[1];
    wire curr_p = cc[0];

    wire ir11 = ir[11];
    wire ir10 = ir[10];
    wire ir9 = ir[9];

    always_ff @(posedge clk) begin
        if(ldben) begin
            ben <= ir11 & curr_n | ir10 & curr_z | ir9 & curr_p;
        end
    end
endmodule

module cc_reg(clk, ldcc, bus, cc); 
    input clk;
    input ldcc;
    input [15:0] bus;
    output reg [2:0] cc;

    wire n = bus[15];
    wire z = (bus == 0);
    wire p = ~n & ~z;

    always_ff @(posedge clk) begin
        if(ldcc) begin
            cc <= n ? 3'b100 : (z ? 3'b010 : (p ? 3'b001 : 3'b000));
        end
    end
endmodule

module pc_reg(clk, ldpc, pcmux_out, pc);
    input clk;
    input ldpc;
    input [15:0] pcmux_out;
    output reg [15:0] pc;

    always_ff @(posedge clk) begin
        if(ldpc) begin
            pc <= pcmux_out;
        end
    end
endmodule

module mar_reg(clk, ldmar, bus, mar);
    input clk;
    input ldmar;
    input [15:0] bus;
    output reg [15:0] mar;

    always_ff @(posedge clk) begin
        if(ldmar) begin
            mar <= bus[15:0];
        end
    end
endmodule

module mdr_reg(clk, ldmdr, mioen_out, mdr);
    input clk;
    input ldmdr;
    input [15:0] mioen_out;
    output reg [15:0] mdr;

    always_ff @(posedge clk) begin
        if(ldmdr) begin
            mdr <= mioen_out;
        end
    end
endmodule

//////////memory management//////////
module mdr_in_logic(clk, bus, data_size, mdr_in_mioen_mux);
    input clk;
    input [15:0] bus;
    input data_size;
    output reg [15:0] mdr_in_mioen_mux;

    always_comb begin
        if(data_size) begin
            mdr_in_mioen_mux = bus[15:0];
        end
        else begin
            mdr_in_mioen_mux = {bus[7:0], bus[7:0]};
        end
    end
endmodule

module mio_en_mux(clk, mio_en, mdr_in_mioen_mux, mdr_val_from_mem, mioen_out);
    input clk;
    input mio_en;
    input [15:0] mdr_in_mioen_mux;
    input [15:0] mdr_val_from_mem;
    output reg [15:0] mioen_out;

    always_comb begin
        if(mio_en) begin
            mioen_out = mdr_val_from_mem;
        end
        else begin
            mioen_out = mdr_in_mioen_mux;
        end
    end
endmodule

module mdr_out_logic(clk, mdr, data_size, mar0, mdr_out);
    input clk;
    input [15:0] mdr;
    input data_size;
    input mar0;
    output reg [15:0] mdr_out;

    always_comb begin
        if(data_size) begin
            mdr_out = mdr;
        end
        else begin
            mdr_out = mar0 ? {8'h00, mdr[15:8]} : {8'h00, mdr[7:0]};
        end
    end
endmodule

module we_logic(clk, rw, mar0, data_size, we_out);
    input clk;
    input rw;
    input mar0;
    input data_size;
    output reg [1:0] we_out; //we1 for high byte, we0 for low byte

    always_ff @(posedge clk) begin
        if(rw) begin
            we_out[0] <= (!mar0 && !data_size) || (data_size && !mar0);
            we_out[1] <= (mar0 && !data_size) || (data_size && !mar0);
        end
        else begin
            we_out <= 2'b00;
        end
    end
endmodule