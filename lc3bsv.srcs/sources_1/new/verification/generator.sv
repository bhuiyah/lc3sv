`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2024 05:57:08 PM
// Design Name: 
// Module Name: generator
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


class generator;

    //declaring transaction class
    rand transaction trans, tr_deep_copy;

    //declaring mailbox
    mailbox gen2driv;

    //repeat count, to specify number of packets to be generated
    int repeat_count;

    //event to be triggered when generation is complete
    event gen_complete;

    //constructor
    function new(mailbox gen2driv, gen_complete);
        //mailbox provided from environment
        this.gen2driv = gen2driv;
        //event provided from environment
        this.gen_complete = gen_complete;
    endfunction

    //main task, generates (creates and randomizes) the packets and puts into mailbox
    task main();
        repeat(repeat_count) begin
            trans = new();
            if(!trans.randomize()) $fatal("Gen:: Failed to randomize transaction");
            tr_deep_copy = trans.deep_copy();
            gen2driv.put(tr_deep_copy);
        end
        -> gen_complete;
        
    endtask

endclass
