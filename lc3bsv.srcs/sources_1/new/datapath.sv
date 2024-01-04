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

`include "sign_extend.vh"
import sign_extend::*;

module datapath(clk, cs, we, address, memory_bus, control_signals, opcode, ir11, ben, rw, r, start_pc, memory_initialized, pc, gate_en, load_en);
    input clk;
    input [34:0] control_signals;
    input r;
    input [15:0] start_pc;
    input memory_initialized;
    input gate_en;
    input load_en;

    inout [15:0] memory_bus;

    output cs;
    output [1:0] we;
    output [15:0] address;
    output [3:0] opcode;
    output ir11;
    output ben;
    output rw;
    output [15:0] pc;

    //control signals from control store
    wire lshf1 = control_signals[0];
    wire data_size = control_signals[1];
    wire mio_en = control_signals[3];
    wire [1:0] aluk = {control_signals[5], control_signals[4]};
    wire marmux = control_signals[6];
    wire [1:0] addr2mux = {control_signals[8], control_signals[7]};
    wire addr1mux = control_signals[9];
    wire sr1mux = control_signals[10];
    wire drmux = control_signals[11];
    wire [1:0] pcmux = {control_signals[13], control_signals[12]};
    wire gateshf = control_signals[14];
    wire gatemarmux = control_signals[15];
    wire gatealu = control_signals[16];
    wire gatemdr = control_signals[17];
    wire gatepc = control_signals[18];
    wire ldpc = control_signals[19];
    wire ldcc = control_signals[20];
    wire ldreg = control_signals[21];
    wire ldben = control_signals[22];
    wire ldir = control_signals[23];
    wire ldmdr = control_signals[24];
    wire ldmar = control_signals[25];
    
    wire [15:0] instruction;
    wire [2:0] sr1 = sr1mux ? instruction[8:6] : instruction[11:9];
    wire [2:0] sr2 = instruction[2:0];
    wire [2:0] dr = drmux ? 3'b111 : instruction[11:9];
    wire [15:0] readreg1, readreg2;
    wire [15:0] alu_out, shf_out, mdr_out, marmux_out, pcmux_out;
    wire [15:0] bus_contents;
    wire [15:0] A, B;
    wire [15:0] mar, mdr;
    wire [2:0] cc;
    wire [15:0] addr1_out, addr2_out, lshf1_out, adder_out;
    wire [15:0] mdr_in_mioen_mux;
    wire [15:0] mioen_out;
    wire [15:0] mdr_val_from_mem;
    wire [1:0] we_out;
    wire initialized;

    assign opcode = instruction[15:12];
    assign cs = mio_en;
    assign we = we_out;
    assign rw = control_signals[2];
    assign ir11 = instruction[11];
    assign mdr_val_from_mem = (mio_en && !rw && r) ? memory_bus : 16'h0000;
    assign A = readreg1;
    assign address = mar;
    assign initialized = (pc == start_pc) || pc != 16'h0000;

    //wiring the datapath
    register_file reg_file(.clk(clk), .reg_write(ldreg), .DR(dr), .SR1(sr1), .SR2(sr2), .Reg_In(bus_contents), .ReadReg1(readreg1), .ReadReg2(readreg2));
    bus b_u_s(.alu_out(alu_out), .shf_out(shf_out), .mdr_out(mdr_out), .pc_out(pc), .marmux_out(marmux_out), .gatealu(gatealu), .gateshf(gateshf), .gatemdr(gatemdr), .gatepc(gatepc), .gatemarmux(gatemarmux), .bus_contents(bus_contents), .gate_en(gate_en));
    sr2_mux sr2_mux(.sr2muxsignal(instruction[5]), .readreg2(readreg2), .imm5(instruction[4:0]), .sr2_out(B));
    alu a_l_u(.A(A), .B(B), .aluk(aluk), .alu_out(alu_out));
    shf s_h_f(.A(A), .ir5_4(instruction[5:4]), .ammt4(instruction[3:0]), .shf_out(shf_out));
    addr1_mux addr1_mx(.addr1mux(addr1mux), .pc(pc), .readreg1(readreg1), .addr1_out(addr1_out));
    addr2_mux addr2_mx(.addr2mux(addr2mux), .ir(instruction), .addr2_out(addr2_out));
    lshf1mod lshf(.lshf1(lshf1), .in(addr2_out), .lshf1_out(lshf1_out));
    adder_for_marmux_or_pcmux adder(.lshf1_in(lshf1_out), .addr1mux_in(addr1_out), .adder_out(adder_out));
    mar_mux mar_mx(.marmux(marmux), .adder_out(adder_out), .ir(instruction), .marmux_out(marmux_out));
    pc_mux pc_mx(.pcmux(pcmux), .adder_out(adder_out), .bus(bus_contents), .pc(pc), .pcmux_out(pcmux_out));

    //loading registers
    ir_reg ir_r(.ld_ir(ldir), .bus(bus_contents), .ir_out(instruction), .load_en(load_en));
    ben_reg ben_r(.ldben(ldben), .ir(instruction), .cc(cc), .ben(ben), .load_en(load_en));
    cc_reg cc_r(.ldcc(ldcc), .bus(bus_contents), .cc(cc), .load_en(load_en));
    pc_reg pc_r(.ldpc(ldpc), .pcmux_out(pcmux_out), .pc_out(pc), .start_pc(start_pc), .memory_initialized(memory_initialized), .initialized(initialized), .load_en(load_en));
    mar_reg mar_r(.ldmar(ldmar), .bus(bus_contents), .mar_out(mar), .load_en(load_en));
    mdr_reg mdr_r(.ldmdr(ldmdr), .mioen_out(mioen_out), .mdr_out(mdr), .load_en(load_en), .r(r));

    //memory management
    mdr_in_logic mdr_in(.bus(bus_contents), .data_size(data_size), .mdr_in_mioen_mux(mdr_in_mioen_mux));
    mio_en_mux mio_en_mx(.mio_en(mio_en), .mdr_in_mioen_mux(mdr_in_mioen_mux), .mdr_val_from_mem(mdr_val_from_mem), .mioen_out(mioen_out));
    mdr_out_logic mdr_out_log(.mdr(mdr), .data_size(data_size), .mar0(mar[0]), .mdr_out(mdr_out));
    we_logic we_l(.rw(rw), .mar0(mar[0]), .data_size(data_size), .we_out(we_out));

endmodule

module bus(alu_out, shf_out, mdr_out, pc_out, marmux_out, gatealu, gateshf, gatemdr, gatepc, gatemarmux, bus_contents, gate_en);
    input [15:0] alu_out;
    input [15:0] shf_out;
    input [15:0] mdr_out;
    input [15:0] pc_out;
    input [15:0] marmux_out;
    input bit gatealu, gateshf, gatemdr, gatepc, gatemarmux;
    input gate_en;
    output reg [15:0] bus_contents;

    always_latch begin
        if(gate_en) begin
            if(gatealu) begin
                bus_contents = alu_out;
                $display("bus_contents = %b", bus_contents);
            end
            else if(gateshf) begin
                bus_contents = shf_out;
                $display("bus_contents = %b", bus_contents);
            end
            else if(gatemdr) begin
                bus_contents = mdr_out;
                $display("bus_contents = %b", bus_contents);
            end
            else if(gatepc) begin
                bus_contents = pc_out;
                $display("bus_contents = %b", bus_contents);
            end
            else if(gatemarmux) begin
                bus_contents = marmux_out;
                $display("bus_contents = %b", bus_contents);
            end
        end
    end

endmodule

module alu(A, B, aluk, alu_out);
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

module shf(A, ir5_4, ammt4, shf_out);
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

module sr2_mux(sr2muxsignal, readreg2, imm5, sr2_out);
    input bit sr2muxsignal;
    input [15:0] readreg2;
    input [4:0] imm5;
    output reg [15:0] sr2_out;

    always_comb begin
        sr2_out = sr2muxsignal ? sext({11'h000, imm5}, 5) : readreg2;
    end

endmodule

module addr1_mux(addr1mux, pc, readreg1, addr1_out);
    input addr1mux;
    input [15:0] pc;
    input [15:0] readreg1;
    output reg [15:0] addr1_out;

    always_comb begin
        addr1_out = addr1mux ? readreg1 : pc;
    end
endmodule

module addr2_mux(addr2mux, ir, addr2_out);
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

module lshf1mod(lshf1, in, lshf1_out);
    input lshf1;
    input [15:0] in;
    output reg [15:0] lshf1_out;

    always_comb begin
        lshf1_out = lshf1 ? (in << 1) : in;
    end
endmodule

module adder_for_marmux_or_pcmux(lshf1_in, addr1mux_in, adder_out);
    input [15:0] lshf1_in;
    input [15:0] addr1mux_in;
    output reg [15:0] adder_out;

    always_comb begin
        adder_out = lshf1_in + addr1mux_in;
    end

endmodule

module mar_mux(marmux, adder_out, ir, marmux_out);
    input marmux;
    input [15:0] adder_out;
    input [15:0] ir;
    output reg [15:0] marmux_out;

    always_comb begin
        marmux_out = marmux ? adder_out : (ir & 16'h00FF) << 1;
    end
endmodule

module pc_mux(pcmux, adder_out, bus, pc, pcmux_out);
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
                pcmux_out = bus;
            end
            2'b10: begin
                pcmux_out = adder_out;
            end
            2'b11: begin
                pcmux_out = pc;
            end
        endcase
    end
endmodule

//////////loading registers//////////
module ir_reg(ld_ir, bus, ir_out, load_en);
    input ld_ir;
    input load_en;
    input [15:0] bus;
    output [15:0] ir_out;

    reg [15:0] ir;

    assign ir_out = ir;

    always@(posedge load_en) begin
        if(ld_ir) begin
            ir = bus[15:0];
            $display("ir = %b", ir);
        end
    end
endmodule

module ben_reg(ldben, ir, cc, ben, load_en); 
    input ldben;
    input [15:0] ir;
    input [2:0] cc;
    input load_en;
    output reg ben;

    wire curr_n = cc[2];
    wire curr_z = cc[1];
    wire curr_p = cc[0];

    wire ir11 = ir[11];
    wire ir10 = ir[10];
    wire ir9 = ir[9];

    always@(posedge load_en) begin
        if(ldben) begin
            ben = ir11 & curr_n | ir10 & curr_z | ir9 & curr_p;
            $display("ben = %b", ben);
        end
    end
endmodule

module cc_reg(ldcc, bus, cc, load_en); 
    input ldcc;
    input [15:0] bus;
    input load_en;
    output reg [2:0] cc;

    wire n = bus[15];
    wire z = (bus == 0);
    wire p = ~n & ~z;

    always@(posedge load_en) begin
        if(ldcc) begin
            cc = n ? 3'b100 : (z ? 3'b010 : (p ? 3'b001 : 3'b000));
            $display("cc = %b", cc);
        end
    end
endmodule

module pc_reg(ldpc, pcmux_out, pc_out, start_pc, memory_initialized, initialized, load_en);
    input ldpc;
    input [15:0] pcmux_out;
    input [15:0] start_pc;
    input memory_initialized;
    input initialized;
    input load_en;
    output [15:0] pc_out;

    bit [15:0] pc;

    assign pc_out = pc;

    always@(posedge load_en) begin
        if(ldpc) begin
            pc = pcmux_out;
            $display("pc = %b", pc);
        end
    end

    always@(posedge memory_initialized) begin
        if(!initialized) begin
            pc = start_pc;
            $display("pc = %b", pc);
        end
    end
endmodule

module mar_reg(ldmar, bus, mar_out, load_en);
    input ldmar;
    input [15:0] bus;
    input load_en;
    output [15:0] mar_out;

    reg [15:0] mar;

    assign mar_out = mar;

    always@(posedge load_en) begin
        if(ldmar) begin
            mar = bus;
            $display("mar = %b", mar);
        end
    end
endmodule

module mdr_reg(ldmdr, mioen_out, mdr_out, load_en, r);
    input ldmdr;
    input [15:0] mioen_out;
    input load_en;
    input r;
    output [15:0] mdr_out;

    reg [15:0] mdr;

    assign mdr_out = mdr;

    always@(posedge load_en) begin
        if(ldmdr && r) begin
            mdr = mioen_out;
            $display("mdr = %b", mdr);
        end
    end
endmodule

//////////memory management//////////
module mdr_in_logic(bus, data_size, mdr_in_mioen_mux);
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

module mio_en_mux(mio_en, mdr_in_mioen_mux, mdr_val_from_mem, mioen_out);
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

module mdr_out_logic(mdr, data_size, mar0, mdr_out);
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

module we_logic(rw, mar0, data_size, we_out);
    input rw;
    input mar0;
    input data_size;
    output reg [1:0] we_out; //we1 for high byte, we0 for low byte

    always_comb begin
        if(rw) begin
            we_out[0] = (!mar0 && !data_size) || (data_size && !mar0);
            we_out[1] = (mar0 && !data_size) || (data_size && !mar0);
        end
        else begin
            we_out = 2'b00;
        end
    end
endmodule