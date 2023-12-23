`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2023 07:19:34 PM
// Design Name: 
// Module Name: memory
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


module memory(cs, we, clk, rw, address, memory_bus, r);
    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address;
    inout [15:0] memory_bus;
    output r;

    reg [15:0] data_out;
    reg [7:0] DRAM [16'h08000][2];
    reg [3:0] cycle_count;
    reg [14:0] acc_addr;

    assign memory_bus = ((cs == 0) || (we == 1)) ? 16'bZ : data_out;
    assign r = (cycle_count == 5);
    assign acc_addr = address[15:1];

    initial begin
        //$readmemh(); //will add with instructions, vectors, etc.
        cycle_count = 0;
    end

    always_ff @(negedge clk) begin
        //write to memory
        if(cs) begin //cs = mio_en
            if(cycle_count == 5) begin //5 cycles to read or write to DRAM
                if(rw) begin //write
                    if(we[0])
                        DRAM[acc_addr][0] <= memory_bus[7:0];

                    if(we[1])
                        DRAM[acc_addr][1] <= memory_bus[15:8];
                end
                else //read
                    data_out <= {DRAM[acc_addr][0], DRAM[acc_addr][1]};
                cycle_count <= 0; //reset cycle count after accessing DRAM
            end else
                cycle_count <= cycle_count + 1;
        end
    end
endmodule
