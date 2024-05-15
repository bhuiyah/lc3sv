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

typedef enum {
    IDLE, READ, READMISS, READMEM, READDATA, WRITE, WRITEHIT, WRITEMISS, WRITEMEM, WRITEDATA, UPDATECACHE
} states;

module SRAM(cs, we, clk, rw, address, memory_bus, cache_line_bus
    `ifdef SIMULATE_CPU
        , r_mem, r_cache
    `endif
        , cache_hit, mem_en
    );

    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address;
    inout [15:0] memory_bus;
    inout [31:0] cache_line_bus;

    `ifdef SIMULATE_CPU
        input r_mem;
        output reg r_cache;
    `endif

    //cache signals
    output reg cache_hit;
    output reg mem_en;

    //SRAM cache, 4B cache line, 4-way set associative, 8 sets
    //11b tag, 3b index, 2b offset
    //1b valid, 1b dirty, 2b lru, 32b data

    // | 11b tag | 1b valid | 1b dirty | 2b lru | 32b data |
    // | 46:36   | 35       | 34       | 33:32  | 31:0     |

    // 4 ways per set, 8 sets, need 4 hardware comparators
    bit [46:0] cache_way0 [7:0];
    bit [46:0] cache_way1 [7:0];
    bit [46:0] cache_way2 [7:0];
    bit [46:0] cache_way3 [7:0];

    reg [15:0] data_out;
    reg [14:0] acc_addr;
    reg [31:0] cache_read_data;

    //cache signals
    bit [1:0] hit_way;
    bit dirty;
    bit empty;
    bit empty_way;
    bit [1:0] lru_way;

    integer i;

    //state machine
    reg [3:0] state;
    reg [3:0] next_state;

    assign memory_bus = ((cs == 0) || (we == 1) || !(cache_hit)) || (mem_en) ? 16'bZ : data_out;
    assign acc_addr = address[15:1];

    task automatic check_cache(output bit hit, output bit dirty, output bit [1:0] way);
        hit = 0;
        if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
            way = 0;
            if(cache_way0[`addr_idx][`valid_bit]) begin
                if(!cache_way0[`addr_idx][`dirty_bit]) begin
                    hit = 1;
                end
                else begin
                    dirty = 1;
                end
            end
        end
        else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
            way = 1;
            if(cache_way1[`addr_idx][`valid_bit]) begin
                if(!cache_way1[`addr_idx][`dirty_bit]) begin
                    hit = 1;
                end
                else begin
                    dirty = 1;
                end
            end
        end
        else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
            way = 2;
            if(cache_way2[`addr_idx][`valid_bit]) begin
                if(!cache_way2[`addr_idx][`dirty_bit]) begin
                    hit = 1;
                end
                else begin
                    dirty = 1;
                end
            end
        end
        else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
            way = 3;
            if(cache_way3[`addr_idx][`valid_bit]) begin
                if(!cache_way3[`addr_idx][`dirty_bit]) begin
                    hit = 1;
                end
                else begin
                    dirty = 1;
                end
            end
        end
        else begin
            hit = 0;
        end
    endtask

    task automatic read_cache(input bit [1:0] hit_way, output reg [15:0] cache_read_data);
        //only read data if cache hit
        if(hit_way == 0) begin
            cache_data_out = cache_way0[`addr_idx];
        end
        else if(hit_way == 1) begin
            cache_data_out = cache_way1[`addr_idx];
        end
        else if(hit_way == 2) begin
            cache_data_out = cache_way2[`addr_idx];
        end
        else if(hit_way == 3) begin
            cache_data_out = cache_way3[`addr_idx];
        end
    endtask

    task automatic cache_empty(output bit empty, output bit [1:0] way);
        //check if cache is empty by checking valid bit
        if(!cache_way0[`addr_idx][`valid_bit]) begin
            empty = 1;
            way = 0;
        end
        else if(!cache_way1[`addr_idx][`valid_bit]) begin
            empty = 1;
            way = 1;
        end
        else if(!cache_way2[`addr_idx][`valid_bit]) begin
            empty = 1;
            way = 2;
        end
        else if(!cache_way3[`addr_idx][`valid_bit]) begin
            empty = 1;
            way = 3;
        end
        else begin
            empty = 0;
        end
    endtask

    task automatic find_lru(output bit [1:0] lru_way);
        //find the least recently used way in the set
        if({cache_way0['addr_idx][33], cache_way0['addr_idx][32]} == 2'b11) begin
            lru_way = 0;
        end
        else if({cache_way1['addr_idx][33], cache_way1['addr_idx][32]} == 2'b11) begin
            lru_way = 1;
        end
        else if({cache_way2['addr_idx][33], cache_way2['addr_idx][32]} == 2'b11) begin
            lru_way = 2;
        end
        else if({cache_way3['addr_idx][33], cache_way3['addr_idx][32]} == 2'b11) begin
            lru_way = 3;
        end

    endtask

    initial begin
        state = IDLE;
        next_state = IDLE;
        cache_hit = 0;
        mem_en = 0;
        hit_way = 0;
        //initialize cache
        for(i = 0; i < 8; i = i + 1) begin
            cache_way0[i] = 0;
            cache_way1[i] = 0;
            cache_way2[i] = 0;
            cache_way3[i] = 0;
        end
        `ifdef SIMULATE_CPU
            r_cache = 0;
        `endif
    end

    always_comb begin
        case(state)
            IDLE: begin
                //wait until mio_en/cs is high meaning we want to access memory
                if(cs && !cache_hit && !mem_en) begin
                    if(rw) begin
                        next_state = WRITE;
                    end
                    else begin
                        next_state = READ;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            READ: begin
                //check if address is in cache
                check_cache(cache_hit, hit_way, dirty);
                if(cache_hit) begin
                    read_cache(hit_way, cache_read_data);
                    //set cache read data to memory bus but need to find high word or low word
                    if(acc_addr[0]) begin
                        memory_bus = cache_read_data[15:0];
                    end
                    else begin
                        memory_bus = cache_read_data[31:16];
                    end

                    `ifdef SIMULATE_CPU
                        r_cache = 1;
                    `endif

                    next_state = IDLE;
                end
                else begin
                    next_state = READMISS;
                end
            end
            READMISS: begin
                mem_en = 1; //cache miss so need to access main memory
                next_state = READMEM;
            end
            READMEM: begin
                //wait 5 cycles to read from memory
                if(r_mem) begin //r_mem is 1 when data is ready from main memory
                    mem_en = 0;
                    next_state = READDATA;
                end
                else begin //wait for data to be ready
                    next_state = READMEM;
                end
            end
            READDATA: begin
                //write data to cache and update lru bits
                //check if cache has an empty way
                cache_empty(empty, empty_way);
                if(empty) begin
                    //write to empty way
                    case(empty_way)
                        2'b00: begin
                            cache_way0[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                        end
                        2'b01: begin
                            cache_way1[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                        end
                        2'b10: begin
                            cache_way2[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                        end
                        2'b11: begin
                            cache_way3[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                        end
                    endcase
                end
                else begin
                    //need to evict a way
                    find_lru(lru_way);
                    case(lru_way)
                        2'b00: begin
                            //check if dirty bit is set
                            if(cache_way0[`addr_idx][`dirty_bit]) begin
                                //write dirty data back to memory
                                //need to implement write back policy
                                //gonna go to a state where we write back to memory
                            end

                            cache_way0[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                            //update lru bits for other ways
                            cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                            cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
                            cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
                        end
                        2'b01: begin
                            cache_way1[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                            //update lru bits for other ways
                            cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                            cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
                            cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
                        end
                        2'b10: begin
                            cache_way2[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                            //update lru bits for other ways
                            cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                            cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                            cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
                        end
                        2'b11: begin
                            cache_way3[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, memory_bus};
                            //update lru bits for other ways
                            cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                            cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                            cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
                        end
                    endcase
                end
                next_state = IDLE;
            end
            WRITE: begin
                //check if address is in cache
                check_cache(cache_hit, hit_way);
                if(cache_hit) begin
                    next_state = WRITEHIT;
                end
                else begin
                    next_state = WRITEMISS;
                end
            end
            WRITEMISS: begin
                next_state = WRITEMEM;
            end
            WRITEMEM: begin
                next_state = WRITEDATA;
            end
            WRITEDATA: begin
                next_state = IDLE;
            end
        endcase

    end

    always@(posedge clk) begin
        state = next_state;
    end



    /*  ////////will come back to this later////////    
    // assign mem_en = (cycle_count == 2);

    // //write to cache
    // task automatic write(input bit ref [46:0] cache_way, input bit [1:0] addr_offset, input [15:0] memory_bus, input [1:0] we);
    //     case(addr_offset)
    //     //if idx is even, able to write to upper and lower bytes
    //     //if idx is odd, only able to write to lower byte
    //     //     | 8b | 8b | 8b | 8b |
    //     //idx: | 3  | 2  | 1  | 0  |
    //         2'b00: begin
    //             if(we[0])
    //                 cache_way[7:0] = memory_bus[7:0];
    //             if(we[1])
    //                 cache_way[15:8] = memory_bus[15:8];
    //         end
    //         2'b01: begin
    //             if(we[0])
    //                 cache_way[15:8] = memory_bus[7:0];
    //         end
    //         2'b10: begin
    //             if(we[0])
    //                 //byte write
    //                 cache_way[23:16] = memory_bus[7:0];
    //             if(we[1])
    //                 cache_way[31:24] = memory_bus[15:8];
    //         end
    //         2'b11: begin
    //             if(we[0])
    //                 cache_way[31:24] = memory_bus[7:0];
    //         end 
    //     endcase
    //     //set dirty bit
    //     cache_way[`dirty_bit] = 1;

    //     //set lru bits

    // endtask


    // initial begin
    //     cache_miss = 0;
    //     `ifdef SIMULATE_CPU
    //         r = 0;
    //     `endif
    // end

    // always@(posedge clk) begin
    //     `ifdef SIMULATE_CPU
    //         r = 0;
    //     `endif
    //     if(mem_en) begin
    //         if(rw) begin //write
    //             //search all ways in the set for the tag
    //             if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
    //                 write(cache_way0[`addr_idx], `addr_offset, memory_bus, we);
    //             end
    //             else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
    //                 write(cache_way1[`addr_idx], `addr_offset, memory_bus, we);
    //             end
    //             else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
    //                 write(cache_way2[`addr_idx], `addr_offset, memory_bus, we);
    //             end
    //             else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
    //                 write(cache_way3[`addr_idx], `addr_offset, memory_bus, we);
    //             end
    //             else begin //cache miss
    //                 cache_miss = 1;
    //             end                
    //         end
    //         else begin //read
    //             //search all ways in the set for the tag
    //             if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
    //                 data_out = read(cache_way0[`addr_idx], `addr_offset);
    //             end
    //             else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
    //                 data_out = read(cache_way1[`addr_idx], `addr_offset);
    //             end
    //             else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
    //                 data_out = read(cache_way2[`addr_idx], `addr_offset);
    //             end
    //             else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
    //                 data_out = read(cache_way3[`addr_idx], `addr_offset);
    //             end
    //             else begin //cache miss
    //                 cache_miss = 1;
    //             end
    //         end
    //         cycle_count = 0; //reset cycle count after accessing cache
    //     end
    // end

    // always@(posedge clk) begin
    //     if(cs && !cache_miss) begin
    //         cycle_count = cycle_count + 1;
    //     end
    // end

    */

endmodule
