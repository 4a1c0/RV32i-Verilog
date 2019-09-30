`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module programCounter (
    rst_n,
    clk,
    offset_i,
    is_branch_i,
    is_absolute_i,
    addr
    );

    input rst_n, clk;
    input is_branch_i;
    input is_absolute_i;
    input [`MEM_ADDR_WIDTH-1:0] offset_i;
    output [`MEM_ADDR_WIDTH-1:0] addr;

    reg [`MEM_ADDR_WIDTH-1:0] addr;

    wire [`MEM_ADDR_WIDTH-1:0] offset;

    assign offset = (is_branch_i === 1'b1)? offset_i : `MEM_ADDR_WIDTH'd4;  // decide to add 4 or offset if is branch

    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin 
            addr <= `MEM_ADDR_WIDTH'd0;
        end 
        else if (is_absolute_i === 1'b1) begin
            addr <= offset;
        end
        else begin
            addr <= addr + offset;
        end
    end
endmodule
