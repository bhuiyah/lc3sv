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

module datapath(clk, cs, we, address, memory_bus, control_signals, opcode, ir11, ben, rw);
    input clk;
    input [15:0] address;
    input [34:0] control_signals;

    inout [31:0] memory_bus;

    output cs;
    output [1:0] we;
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
    bit [1:0] pcmux = control_signals[pcmux1_idx:pcmux0_idx];
    bit [1:0] addr2mux = control_signals[addr2mux1_idx:addr2mux0_idx];
    bit [1:0] aluk = control_signals[aluk1_idx:aluk0_idx];
    bit lshf1 = control_signals[lshf1_idx];
    bit [1:0] drmux = control_signals[drmux_idx];
    bit [1:0] sr1mux = control_signals[sr1mux_idx];
    bit [1:0] addr1mux = control_signals[addr1mux_idx];
    bit [1:0] marmux = control_signals[marmux_idx];
    bit lshf1 = control_signals[lshf1_idx];
    bit data_size = control_signals[data_size_idx];
    bit mio_en = control_signals[mio_en_idx];
    
    reg [15:0] instruction;

    wire sr1 = sr1mux ? instruction[8:6] : instruction[11:9];
    wire sr2 = instruction[2:0];
    wire dr = drmux ? 3'b111 : instruction[11:9];

    assign opcode = instruction[15:12];
    assign cs = mio_en;
    assign we = we_out;
    assign rw = control_signals[r_w_idx];

    wire [31:0] readreg1, readreg2;
    register_file reg_file(.clk(clk), .reg_write(ldreg), .DR(dr), .SR1(sr1), .SR2(sr2), .Reg_In(reg_input), .ReadReg1(readreg1), .ReadReg2(readreg2));
    
endmodule

module bus(clk, alu_out, shf_out, mdr_out, pc_out, marmux_out, gatealu, gateshf, gatemdr, gatepc, gatemarmux, bus_contents);
    input clk;
    input [15:0] alu_out;
    input [15:0] shf_out;
    input [15:0] mdr_out;
    input [15:0] pc_out;
    input [15:0] marmux_out;
    input bit gatealu, gateshf, gatemdr, gatepc, gatemarmux;
    output reg [31:0] bus_contents;

    always_ff @(posedge clk) begin
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
            bus_contents <= 32'h00000000;
        end
    end
endmodule

module alu(clk, A, B, aluk, alu_out);
    input clk;
    input [15:0] A;
    input [15:0] B;
    input bit [1:0] aluk;
    output reg [15:0] alu_out;

    always_ff @(posedge clk) begin
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

    always_ff @(posedge clk) begin
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

module sr2_mux(clk, sr2muxsignal, readreg2, imm5, sr2_out);
    import packaged_functions::*;
    input clk;
    input bit sr2muxsignal;
    input [15:0] readreg2;
    input [4:0] imm5;
    output reg [15:0] sr2_out;

    always_ff @(posedge clk) begin
        sr2_out <= sr2muxsignal ? sext(imm5, 16) : readreg2;
    end

endmodule

module addr1_mux(clk, addr1mux, pc, readreg1, addr1_out);
    input clk;
    input addr1mux;
    input [15:0] pc;
    input [15:0] readreg1;
    output reg [15:0] addr1_out;

    always_ff @(posedge clk) begin
        addr1_out <= addr1mux ? readreg1 : pc;
    end
endmodule

module addr2_mux(clk, addr2mux, ir, addr2_out);
    input clk;
    input [1:0] addr2mux;
    input [15:0] ir;
    output reg [15:0] addr2_out;

    always_ff @(posedge clk) begin
        case(addr2mux)
            2'b00: begin
                addr2_out <= 16'h0000;
            end
            2'b01: begin
                addr2_out <= sext(ir[5:0], 16);
            end
            2'b10: begin
                addr2_out <= sext(ir[8:0], 16);
            end
            2'b11: begin
                addr2_out <= sext(ir[10:0], 16);
            end
        endcase
    end
endmodule

module lshf1(clk, lshf1, in, lshf1_out);
    input clk;
    input lshf1;
    input [15:0] in;
    output reg [15:0] lshf1_out;

    always_ff @(posedge clk) begin
        lshf1_out <= lshf1 ? (in << 1) : in;
    end
endmodule

module adder_for_marmux_or_pcmux(clk, lsfh1_in, addr1mux_in, adder_out);
    input clk;
    input [15:0] lsfh1_in;
    input [15:0] addr1mux_in;
    output reg [15:0] adder_out;

    always_ff @(posedge clk) begin
        adder_out <= lsfh1_in + addr1mux_in;
    end

endmodule

module mar_mux(clk, marmuxsignal, adder_out, ir, marmux_out);
    input clk;
    input marmuxsignal;
    input [15:0] adder_out;
    input [15:0] ir;
    output reg [15:0] marmux_out;

    always_ff @(posedge clk) begin
        marmux_out <= marmuxsignal ? adder_out : (ir & 16'h00FF) << 1;
    end
endmodule

module pc_mux(clk, pcmuxsignal, adder_out, bus, pc, pcmux_out);
    input clk;
    input pcmuxsignal;
    input [15:0] adder_out;
    input [31:0] bus;
    input [15:0] pc;
    output reg [15:0] pcmux_out;

    always_ff @(posedge clk) begin
        case(pcmuxsignal)
            2'b00: begin
                pcmux_out <= pc + 2;
            end
            2'b01: begin
                pcmux_out <= bus[15:0];
            end
            2'b10: begin
                pcmux_out <= adder_out;
            end
            default: begin
                pcmux_out <= pc;
            end
        endcase
    end
endmodule

//////////loading registers//////////
module ir_reg(clk, ld_ir, bus, ir);
    input clk;
    input ld_ir;
    input [31:0] bus;
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
    input [31:0] bus;
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
    input [31:0] bus;
    input data_size;
    output reg [15:0] mdr_in_mioen_mux;

    always_ff @(posedge clk) begin
        if(data_size) begin
            mdr_in_mioen_mux <= bus[15:0];
        end
        else begin
            mdr_in_mioen_mux <= {bus[7:0], bus[7:0]};
        end
    end
endmodule

module mio_en_mux(clk, mio_en, mdr_in_mioen_mux, mdr_val_from_mem, mioen_out);
    input clk;
    input mio_en;
    input [15:0] mdr_in_mioen_mux;
    input [15:0] mdr_val_from_mem;
    output reg [15:0] mioen_out;

    always_ff @(posedge clk) begin
        if(mio_en) begin
            mioen_out <= mdr_val_from_mem;
        end
        else begin
            mioen_out <= mdr_in_mioen_mux;
        end
    end
endmodule

module mdr_out_logic(clk, mdr, data_size, mar0, mdr_out);
    input clk;
    input [15:0] mdr;
    input data_size;
    input mar0;
    output reg [15:0] mdr_out;

    always_ff @(posedge clk) begin
        if(data_size) begin
            mdr_out <= mdr;
        end
        else begin
            mdr_out <= mar0 ? mdr[15:8] : mdr[7:0];
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
            we[0] <= (!mar0 && !data_size) || (data_size && !mar0);
            we[1] <= (mar0 && !data_size) || (data_size && !mar0);
        end
        else begin
            we <= 2'b00;
        end
    end
endmodule