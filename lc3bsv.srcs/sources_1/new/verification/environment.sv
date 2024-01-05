`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2024 11:04:17 PM
// Design Name: 
// Module Name: environment
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

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"

class environment;
    generator gen;
    driver driv;
    mailbox gen2driv;

    event gen_complete;

    virtual mem_intf mem_vif;

    function new(virtual mem_intf mem_vif);
        this.mem_vif = mem_vif;
        gen2driv = new();
        gen = new(gen2driv, gen_complete);
        driv = new(gen2driv, mem_vif);
    endfunction

    task pre_test();
        driv.reset();   
    endtask

    task test();
        fork
            gen.main();
            driv.main();
        join_any
    endtask

    task post_test();
        wait(gen_complete.triggered);
        wait(gen.repeat_count == drive.no_transactions);
        $display("Tests Completed Successfully");
    endtask

    task run;
        pre_test();
        test();
        post_test();
        $finish;
    endtask

endclass
