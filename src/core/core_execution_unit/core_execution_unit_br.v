// Branching moduele

`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

module 	br (
		BR_op_i,
		alu_d,
		old_pc_i,
		new_pc_i,
		new_pc_o,
        is_conditional_i,
        ALU_zero_i
	);

    input [`BR_OP_WIDTH-1:0] BR_op_i;
    input [`REG_DATA_WIDTH-1:0] alu_d;
    input [`REG_DATA_WIDTH-1:0] old_pc_i;
    output [`REG_DATA_WIDTH-1:0] new_pc_o;
    input [`REG_DATA_WIDTH-1:0] new_pc_i;
    input is_conditional_i;
    input ALU_zero_i;

    reg [`REG_DATA_WIDTH-1:0] offset;

    assign new_pc_o = (is_conditional_i === 1'b0)? alu_d: offset;

always @* begin
    case (BR_op_i)
        `BR_EQ: offset = (ALU_zero_i === 1'd1)? new_pc_i: `REG_DATA_WIDTH'd4;
        `BR_NE: offset = (ALU_zero_i === 1'd0)? new_pc_i: `REG_DATA_WIDTH'd4;
        `BR_LT: offset = (ALU_zero_i === 1'd0)? new_pc_i: `REG_DATA_WIDTH'd4;
        `BR_GE: offset = (ALU_zero_i === 1'd1)? new_pc_i: `REG_DATA_WIDTH'd4; 
    endcase
end

endmodule