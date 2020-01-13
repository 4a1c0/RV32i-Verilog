`timescale 1ns/1ps
`default_nettype none

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module programCounter 
    `ifdef CUSTOM_DEFINE
		#(parameter REG_DATA_WIDTH = `REG_DATA_WIDTH) 
	`else
		#(parameter REG_DATA_WIDTH = 32) 
	`endif
    (
    rst_n,
    clk,
    new_pc_i,  // New PC
    pc, // PC
    reg_pc_o
    );

    input rst_n, clk;
    input [REG_DATA_WIDTH-1:0] new_pc_i;
    output [REG_DATA_WIDTH-1:0] pc;
    output [REG_DATA_WIDTH-1:0] reg_pc_o;

    wire [REG_DATA_WIDTH-1:0] new_pc;
    reg [REG_DATA_WIDTH-1:0] pc;
    reg [REG_DATA_WIDTH-1:0] reg_pc_o;

    

    //assign new_pc = (is_branch_i === 1'b1)? new_pc_i : {{REG_DATA_WIDTH-3{1'b0}},3'd4};  // decide to add 4 or new_pc if is branch
    //assign new_pc = new_pc_i; 
    always@(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin 
            pc <= {REG_DATA_WIDTH{1'b0}};  //{{REG_DATA_WIDTH-2{1'b1}}, 2'b00};
            reg_pc_o <= {REG_DATA_WIDTH{1'b0}};
        end 
        else begin
            pc <= new_pc_i;
            reg_pc_o <= pc;
        end
    end
endmodule
`default_nettype wire