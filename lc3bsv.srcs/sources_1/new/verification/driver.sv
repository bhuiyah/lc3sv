`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2024 09:14:21 PM
// Design Name: 
// Module Name: driver
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

`define DRIV_IF mem_vif.DRIVER.driver_cb
`include "transaction.sv"

class driver;

    //declaring mailbox
    mailbox gen2driv;

    //declaring virtual interface handle
    virtual mem_intf mem_vif;

    //number of transactions
    int no_transactions = 0;

    integer i;

    //constructor
    function new(mailbox gen2driv, virtual mem_intf mem_vif);
        //getting the interface handle
        this.mem_vif = mem_vif;
        //getting the mailbox handle from environment
        this.gen2driv = gen2driv;
    endfunction

    //reset task. Reset the intervace signals to default values
    task reset();
        wait(mem_vif.reset);
        $display("--------- [DRIVER] Reset Started ---------");
        `DRIV_IF.cs <= 0;
        `DRIV_IF.we <= 0;
        `DRIV_IF.rw <= 0;
        `DRIV_IF.address <= 0;
        `DRIV_IF.memory_bus <= 0;
        $display("--------- [DRIVER] Reset Finished ---------");
    endtask

    //drives the transaction items to interface signals
    task drive;
        forever begin
            transaction trans;
            `DRIV_IF.cs <= 0;
            `DRIV_IF.we <= 0;
            `DRIV_IF.rw <= 0;
            gen2driv.get(trans);
            $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
            @(posedge mem_vif.DRIVER.clk);
            `DRIV_IF.address <= trans.address;
            if(trans.cs) begin
                `DRIV_IF.cs <= trans.cs;
                if(trans.rw) begin // write
                    `DRIV_IF.memory_bus <= trans.memory_bus;
                    `DRIV_IF.rw <= trans.rw;
                    `DRIV_IF.we <= trans.we;
                    //display all the signals
                    $display("cs = %b, we = %b, rw = %b, address = %h, memory_bus = %h", trans.cs, trans.we, trans.rw, trans.address, trans.memory_bus);
                    //access to memory takes 5 clock cycles
                    for(i = 0; i < 5; i++) begin
                        @(posedge mem_vif.DRIVER.clk);
                    end
                end
                else begin
                    `DRIV_IF.rw <= trans.rw;
                    //access to memory takes 5 clock cycles
                    for(i = 0; i < 5; i++) begin
                        @(posedge mem_vif.DRIVER.clk);
                    end
                    `DRIV_IF.cs <= 0;
                    @(posedge mem_vif.DRIVER.clk);
                    trans.memory_bus = `DRIV_IF.memory_bus;
                    //display all the signals
                    $display("memory_bus = %h, address = %h", `DRIV_IF.memory_bus, trans.address);
                end
                $display("------------------------------------------");
            end
            else begin
                $display("Skipped transaction. Chip select is low. transaction number = %0d", no_transactions);
            end
            no_transactions++;
        end
    endtask

endclass
