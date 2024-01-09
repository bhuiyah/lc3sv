`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/09/2024 09:49:20 PM
// Design Name: 
// Module Name: SRAM
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
`define addr_tag address[15:5]
`define addr_idx address[4:2]
`define addr_offset address[1:0]

`define dirty_bit 34
`define valid_bit 35

module SRAM(cs, we, clk, rw, address, memory_bus
    `ifdef SIMULATE_CPU
        , r, memory_initialized
    `endif
        , cache_miss
    );

    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address;
    inout [15:0] memory_bus;

    `ifdef SIMULATE_CPU
        output reg r;
        output reg memory_initialized;
    `endif

    output reg cache_miss;

    //SRAM cache, 4B cache line, 4-way set associative, 8 sets
    //11b tag, 3b index, 2b offset
    //1b valid, 1b dirty, 2b lru, 32b data

    // | 11b tag | 1b valid | 1b dirty | 2b lru | 32b data |
    // | 46:36   | 35       | 34       | 33:32  | 31:0     |

    // 4 ways per set, 8 sets
    bit [46:0] cache_way0 [7:0];
    bit [46:0] cache_way1 [7:0];
    bit [46:0] cache_way2 [7:0];
    bit [46:0] cache_way3 [7:0];

    reg [15:0] data_out;
    reg [3:0] cycle_count;
    reg [14:0] acc_addr;

    integer i;

    wire mem_en;

    assign memory_bus = ((cs == 0) || (we == 1) || (cache_miss)) ? 16'bZ : data_out;
    assign acc_addr = address[15:1];
    assign mem_en = (cycle_count == 2);

    //write to cache
    task automatic write(input bit ref [46:0] cache_way, input bit [1:0] addr_offset, input [15:0] memory_bus, input [1:0] we);
        case(addr_offset)
        //if idx is even, able to write to upper and lower bytes
        //if idx is odd, only able to write to lower byte
        //     | 8b | 8b | 8b | 8b |
        //idx: | 3  | 2  | 1  | 0  |
            2'b00: begin
                if(we[0])
                    cache_way[7:0] = memory_bus[7:0];
                if(we[1])
                    cache_way[15:8] = memory_bus[15:8];
            end
            2'b01: begin
                if(we[0])
                    cache_way[15:8] = memory_bus[7:0];
            end
            2'b10: begin
                if(we[0])
                    //byte write
                    cache_way[23:16] = memory_bus[7:0];
                if(we[1])
                    cache_way[31:24] = memory_bus[15:8];
            end
            2'b11: begin
                if(we[0])
                    cache_way[31:24] = memory_bus[7:0];
            end 
        endcase
        //set dirty bit
        cache_way[`dirty_bit] = 1;

        //set lru bits

    endtask


    initial begin
        cache_miss = 0;
        `ifdef SIMULATE_CPU
            r = 0;
        `endif
    end

    always@(posedge clk) begin
        `ifdef SIMULATE_CPU
            r = 0;
        `endif
        if(mem_en) begin
            if(rw) begin //write
                //search all ways in the set for the tag
                if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
                    write(cache_way0[`addr_idx], `addr_offset, memory_bus, we);
                end
                else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
                    write(cache_way1[`addr_idx], `addr_offset, memory_bus, we);
                end
                else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
                    write(cache_way2[`addr_idx], `addr_offset, memory_bus, we);
                end
                else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
                    write(cache_way3[`addr_idx], `addr_offset, memory_bus, we);
                end
                else begin //cache miss
                    cache_miss = 1;
                end                
            end
            else begin //read
                //search all ways in the set for the tag
                if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
                    data_out = read(cache_way0[`addr_idx], `addr_offset);
                end
                else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
                    data_out = read(cache_way1[`addr_idx], `addr_offset);
                end
                else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
                    data_out = read(cache_way2[`addr_idx], `addr_offset);
                end
                else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
                    data_out = read(cache_way3[`addr_idx], `addr_offset);
                end
                else begin //cache miss
                    cache_miss = 1;
                end
            end
            cycle_count = 0; //reset cycle count after accessing cache
        end
    end

    always@(posedge clk) begin
        if(cs && !cache_miss) begin
            cycle_count = cycle_count + 1;
        end
    end

endmodule
