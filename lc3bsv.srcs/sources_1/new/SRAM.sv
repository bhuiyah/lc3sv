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
    IDLE, READ, READMISS, READMEM, READDATA, WRITE, WRITEHIT, WRITEMISS, WRITEMEM, WRITEDATA, WRITEBACK, WRITEBACKMEM, UPDATECACHE
} states;

    //SRAM cache, 4B cache line, 4-way set associative, 8 sets
    //11b tag, 3b index, 2b offset
    //1b valid, 1b dirty, 2b lru, 32b data

    // | 11b tag | 1b valid | 1b dirty | 2b lru | 32b data |
    // | 46:36   | 35       | 34       | 33:32  | 31:0     |

module SRAM(cs, we, clk, rw, address, memory_bus, cache_line_bus
    `ifdef SIMULATE_CPU
        , r_mem, r_cache
    `endif
        , cache_hit, mem_en, evict
    );

    input cs;
    input[1:0] we;
    input clk;
    input rw;
    input [15:0] address; //address from cpu
    inout [15:0] memory_bus; //interconnection between cache and cpu
    inout [31:0] cache_line_bus; //interconnection between cache and memory

    `ifdef SIMULATE_CPU
        input r_mem;
        output reg r_cache;
    `endif

    //cache signals
    output reg cache_hit; //signals if cache hit and no need for memory access
    output reg mem_en; //memory access is needed
    output reg evict; //need to access memory to write back cache line
    output reg [15:0] cache_line_address;

    /////////////CACHE ARCHITECTURE/////////////
    // 4 ways per set, 8 sets, need 4 hardware comparators
    bit [46:0] cache_way0 [7:0];
    bit [46:0] cache_way1 [7:0];
    bit [46:0] cache_way2 [7:0];
    bit [46:0] cache_way3 [7:0];
    ////////////////////////////////////////////

    reg [15:0] data_out; //outputs to memory_bus to cpu
    reg [31:0] cache_line_data_out; //outputs to cache_line_bus to memory
    reg [14:0] acc_addr;

    reg[46:0] evicted_cache_line; //holds soon to be evicted cache line and needs to be written back to memory

    //cache signals
    bit [1:0] hit_way; //holds the way that has the cache hit
    bit [1:0] lru_way; //holds the least recently used way
    bit dirty; //dirty?
    bit empty; //is the way empty?
    bit empty_way; //holds the empty way

    integer i; //for loop counter

    //state machine
    reg [3:0] state;
    reg [3:0] next_state;

    //memory_bus connects cache to cpu
    assign memory_bus = ((cs == 0) || (we == 1) || !(cache_hit)) || (mem_en) ? 16'bZ : data_out;
    //cache_line_bus connects cache to main memory
    assign cache_line_bus = ((cs == 0) || (we == 1) || !(cache_hit)) || (mem_en) ? 32'bZ : cache_line_data_out;

    assign acc_addr = address[15:1];

    task automatic check_cache(output bit hit, output bit [1:0] way);
        hit = 0;
        if(cache_way0[`addr_idx][46:36] == `addr_tag) begin
            way = 0;
            if(cache_way0[`addr_idx][`valid_bit] && !cache_way0[`addr_idx][`dirty_bit]) begin
                hit = 1;
            end
        end
        else if(cache_way1[`addr_idx][46:36] == `addr_tag) begin
            way = 1;
            if(cache_way1[`addr_idx][`valid_bit] && !cache_way1[`addr_idx][`dirty_bit]) begin
                hit = 1;
            end
        end
        else if(cache_way2[`addr_idx][46:36] == `addr_tag) begin
            way = 2;
            if(cache_way2[`addr_idx][`valid_bit] && !cache_way2[`addr_idx][`dirty_bit]) begin
                hit = 1;
            end
        end
        else if(cache_way3[`addr_idx][46:36] == `addr_tag) begin
            way = 3;
            if(cache_way3[`addr_idx][`valid_bit] && !cache_way3[`addr_idx][`dirty_bit]) begin
                hit = 1;
            end
        end
        else begin
            hit = 0;
        end
    endtask

    task automatic read_cache(input bit [1:0] hit_way, output reg [31:0] cache_read_data);
        //only read data if cache hit
        if(hit_way == 0) begin
            cache_read_data = cache_way0[`addr_idx][31:0];
        end
        else if(hit_way == 1) begin
            cache_read_data = cache_way1[`addr_idx][31:0];
        end
        else if(hit_way == 2) begin
            cache_read_data = cache_way2[`addr_idx][31:0];
        end
        else if(hit_way == 3) begin
            cache_read_data = cache_way3[`addr_idx][31:0];
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

    task automatic find_dirty(input bit [1:0] lru_way, output bit dirty, output reg [46:0] evicted_cache_line);
        case(lru_way)
            2'b00: begin
                dirty = cache_way0[`dirty_bit];
                evicted_cache_line = cache_way0[`addr_idx];
            end
            2'b01: begin
                dirty = cache_way1[`dirty_bit];
                evicted_cache_line = cache_way1[`addr_idx];
            end
            2'b10: begin
                dirty = cache_way2[`dirty_bit];
                evicted_cache_line = cache_way2[`addr_idx];
            end
            2'b11: begin
                dirty = cache_way3[`dirty_bit];
                evicted_cache_line = cache_way3[`addr_idx];
            end
        endcase
    endtask

    task automatic update_lru_bits(input bit [1:0] lru_way);
        case(lru_way)
            2'b00: begin
                cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
                cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
            end
            2'b01: begin
                cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
                cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
            end
            2'b10: begin
                cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                cache_way3[`addr_idx][33:32] = cache_way3[`addr_idx][33:32] + 1;
            end
            2'b11: begin
                cache_way0[`addr_idx][33:32] = cache_way0[`addr_idx][33:32] + 1;
                cache_way1[`addr_idx][33:32] = cache_way1[`addr_idx][33:32] + 1;
                cache_way2[`addr_idx][33:32] = cache_way2[`addr_idx][33:32] + 1;
            end
        endcase
    endtask

    initial begin
        state = IDLE;
        next_state = IDLE;
        cache_hit = 0;
        mem_en = 0;
        hit_way = 0;
        dirty = 0;
        empty = 0;
        empty_way = 0;
        lru_way = 0;
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
                check_cache(cache_hit, hit_way);
                if(cache_hit) begin
                    read_cache(hit_way, cache_read_data_out);
                    //set cache read data to memory bus but need to find high word or low word
                    if(acc_addr[0]) begin
                        data_out = cache_read_data_out[15:0];
                    end
                    else begin
                        data_out = cache_read_data_out[31:16];
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
                    mem_en = 0; //stops further memory access
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
                            cache_way0[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                        end
                        2'b01: begin
                            cache_way1[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                        end
                        2'b10: begin
                            cache_way2[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                        end
                        2'b11: begin
                            cache_way3[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                        end
                    endcase
                    //need to update the other ways lru bits
                    update_lru_bits(empty_way);

                    `ifdef SIMULATE_CPU
                        r_cache = 1;
                    `endif

                    next_state = IDLE;
                end
                else begin
                    //cache line is full and need to evict a way
                    next_state = WRITEBACK;
                end
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
            WRITEBACK: begin
                find_lru(lru_way);
                //check if lru way is dirty
                find_dirty(lru_way, dirty, evicted_cache_line);
                if(dirty) begin
                    //need to write back to memory
                    evict = 1;
                    mem_en = 1;
                    cache_line_address = {evicted_cache_line[46:36], `addr_idx, 2'b00};
                    next_state = WRITEBACKMEM;
                end
                else begin
                    next_state = UPDATECACHE;
                end
            end
            WRITEBACKMEM: begin
                //wait 5 cycles to write back to memory
                if(r_mem) begin
                    mem_en = 0;
                    next_state = UPDATECACHE;
                end
                else begin
                    next_state = WRITEBACKMEM;
                end
            end
            UPDATECACHE: begin
                //write to lru way
                case(lru_way)
                    2'b00: begin
                        cache_way0[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                    end
                    2'b01: begin
                        cache_way1[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                    end
                    2'b10: begin
                        cache_way2[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                    end
                    2'b11: begin
                        cache_way3[`addr_idx] = {`addr_tag, 1'b1, 1'b0, 2'b00, cache_line_bus};
                    end
                endcase
                //need to update the other ways lru bits
                update_lru_bits(lru_way);

                `ifdef SIMULATE_CPU
                    r_cache = 1;
                `endif

                next_state = IDLE;

            end
        endcase
    end

    always@(posedge clk) begin
        state = next_state;
    end

endmodule
