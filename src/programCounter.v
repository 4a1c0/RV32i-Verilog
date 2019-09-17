`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module programCounter (
    rst_n,
    clk,
    addr
    );

    input rst_n, clk;
    output reg [`MEM_ADDR_WIDTH-1:0] addr;

    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin 
            addr <= `MEM_ADDR_WIDTH'd0;
        end else
        begin
            addr <= addr + `MEM_ADDR_WIDTH'd4;
        end
    end
endmodule
