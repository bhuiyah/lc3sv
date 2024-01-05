`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2024 12:13:37 AM
// Design Name: 
// Module Name: test1
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

// test is responsible for creating the environment
// configuring the testbench ex: setting the type and number of transactions to be generated
// initates the stimulus driving and monitors the response

`include "environment.sv"

program firsttest(mem_intf intf);

    //declaring environment
    environment env;

    initial begin
        //create environment
        env = new(intf);

        //set the repeat count of generator to 10
        env.gen.repeat_count = 10;

        //run of env calls generator and driver main tasks
        env.run();
    end

endprogram
