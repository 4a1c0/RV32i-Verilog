`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module programCounter (
    rst_n,
    clk,
    new_addr_i,
    is_branch_i,
    addr
    );

    input rst_n, clk;
    input is_branch_i;
    input [`MEM_ADDR_WIDTH-1:0] new_addr_i;
    output [`MEM_ADDR_WIDTH-1:0] addr;

    reg [`MEM_ADDR_WIDTH-1:0] addr;

    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin 
            addr <= `MEM_ADDR_WIDTH'd0;
        end 
        else if (is_branch_i == 1'b1) begin
            addr <= new_addr_i;
        end
        else begin
            addr <= addr + `MEM_ADDR_WIDTH'd4;
        end
    end
endmodule
