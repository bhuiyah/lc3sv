`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/09/2024 09:44:05 PM
// Design Name: 
// Module Name: DRAM
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


module DRAM(cs, we, clk, rw, address, memory_bus 
`ifdef SIMULATE_CPU
    , r_mem, start_pc, memory_initialized
`endif
    , cache_miss
);

    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address;
    inout [15:0] memory_bus;
    input cache_hit;
    input mem_en;

    `ifdef SIMULATE_CPU
        output reg r_mem;
        output reg [15:0] start_pc;
        output reg memory_initialized;
    `endif

    reg [15:0] data_out;
    reg [3:0] cycle_count;
    reg [14:0] acc_addr;
    
    bit [15:0] DRAM [16'h08000];

    `ifdef SIMULATE_CPU
        task automatic load_program(input string filename, ref bit [15:0] DRAM [16'h08000], output [15:0] start_pc, output bit memory_initialized);
            bit [14:0] i;
            int file;
            bit [15:0] word;
            bit [14:0] program_base;
            
            bit [31:0] scanRet;
            
            file = $fopen(filename, "r"); //open file for reading
            //read the first line of the file

            if($fscanf(file, "%x\n", word) == 0) begin
                $display("Error: could not read file");
                $finish;
            end

            program_base = word[15:1]; //set program base to the first line of the file shifted right by 1 bit

            //read the rest of the file

            while(!$feof(file)) begin
                scanRet = $fscanf(file, "%x\n", word);
                DRAM[program_base + i] = word;
                i = i + 1;
            end

            $fclose(file);

            start_pc = {program_base, 1'b0}; //set start_pc to the program base shifted left by 1 bit
            memory_initialized = 1;
        endtask
    `endif 
    
    assign memory_bus = ((cs == 0) || (we == 1) || (!cache_miss)) ? 16'bZ : data_out;
    assign acc_addr = address[15:1];

    initial begin
        `ifdef SIMULATE_CPU
        //call task to load program into DRAM
            load_program("test.mem", DRAM, start_pc, memory_initialized);
            r = 0;
        `endif

        cycle_count = 0;
    end

    always@(posedge clk) begin
        //write to memory
        `ifdef SIMULATE_CPU
            r = 0;
        `endif

        if(!cache_hit && mem_en) begin //if cache miss then access DRAM
            if(cs) begin //cs = mio_en
                if(cycle_count == 4) begin //5 cycles to read or write to DRAM
                    if(rw) begin //write
                        if(we[0])
                            DRAM[acc_addr][7:0] = memory_bus[7:0];

                        if(we[1])
                            DRAM[acc_addr][15:8] = memory_bus[15:8];
                    end
                    else //read
                        data_out = DRAM[acc_addr];

                    `ifdef SIMULATE_CPU
                        r_mem = 1;
                    `endif
                        
                    cycle_count = 0; //reset cycle count after accessing DRAM
                end else
                    cycle_count = cycle_count + 1;
            end
        end
    end

endmodule
