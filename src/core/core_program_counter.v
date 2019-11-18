`timescale 1ns/1ps
`default_nettype none

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module programCounter 
    `ifdef CUSTOM_DEFINE
		#(parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH) 
	`else
		#(parameter MEM_ADDR_WIDTH = 10) 
	`endif
    (
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
    input [MEM_ADDR_WIDTH-1:0] offset_i;
    output [MEM_ADDR_WIDTH-1:0] addr;

    reg [MEM_ADDR_WIDTH-1:0] addr;

    wire [MEM_ADDR_WIDTH-1:0] offset;

    assign offset = (is_branch_i === 1'b1)? offset_i : {{MEM_ADDR_WIDTH-3{1'b0}},3'd4};  // decide to add 4 or offset if is branch

    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin 
            addr <= {MEM_ADDR_WIDTH{1'b0}};  //{{MEM_ADDR_WIDTH-2{1'b1}}, 2'b00};
        end 
        else if (is_absolute_i === 1'b1) begin
            addr <= offset;
        end
        else begin
            addr <= addr + offset;
        end
    end
endmodule
`default_nettype wire