// Branching moduele

`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
	`include "../../defines.vh"
`endif

module 	br 
    `ifdef CUSTOM_DEFINE
		#(parameter BR_OP_WIDTH = `BR_OP_WIDTH, 
		parameter DATA_WIDTH = `REG_DATA_WIDTH,
		parameter BR_EQ = `ALU_OP_ADD,
		parameter BR_NE = `ALU_OP_SUB,
		parameter BR_LT = `ALU_OP_SLL,
		parameter BR_GE  = `ALU_OP_SLT) 
	`else
		#(parameter BR_OP_WIDTH = 2, 
		parameter DATA_WIDTH = 32,
		parameter BR_EQ = 0,  // TODO: Separar en localparams
		parameter BR_NE = 1,
		parameter BR_LT = 2,
		parameter BR_GE  = 3) 
	`endif
    (
		BR_op_i,
		alu_d,
		old_pc_i,
		new_pc_i,
		new_pc_o,
        is_conditional_i,
        ALU_zero_i
	);

    input [BR_OP_WIDTH-1:0] BR_op_i;
    input [DATA_WIDTH-1:0] alu_d;
    input [DATA_WIDTH-1:0] old_pc_i;
    output [DATA_WIDTH-1:0] new_pc_o;
    input [DATA_WIDTH-1:0] new_pc_i;
    input is_conditional_i;
    input ALU_zero_i;

    reg [DATA_WIDTH-1:0] offset;

    assign new_pc_o = (is_conditional_i === 1'b0)? alu_d: offset;

always @* begin
    case (BR_op_i)
        BR_EQ: offset = (ALU_zero_i === 1'd1)? new_pc_i: {{DATA_WIDTH-3{1'b0}},1'b0,2'b00};       
        BR_NE: offset = (ALU_zero_i === 1'd0)? new_pc_i: {{DATA_WIDTH-3{1'b0}},1'b0,2'b00};
        BR_LT: offset = (ALU_zero_i === 1'd0)? new_pc_i: {{DATA_WIDTH-3{1'b0}},1'b0,2'b00};
        BR_GE: offset = (ALU_zero_i === 1'd1)? new_pc_i: {{DATA_WIDTH-3{1'b0}},1'b0,2'b00}; 
    endcase
end

endmodule