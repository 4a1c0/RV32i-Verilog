`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
	`include "../../defines.vh"
`endif
module alu
	`ifdef CUSTOM_DEFINE
		#(parameter ALU_OPWIDTH = `ALU_OP_WIDTH, 
		parameter DATA_WIDTH = `REG_DATA_WIDTH,
		parameter ALU_OP_ADD = `ALU_OP_ADD,
		parameter ALU_OP_SUB = `ALU_OP_SUB,
		parameter ALU_OP_SLL = `ALU_OP_SLL,
		parameter ALU_OP_SLT  = `ALU_OP_SLT,
		parameter ALU_OP_SLTU = `ALU_OP_SLTU,
		parameter ALU_OP_XOR = `ALU_OP_XOR,
		parameter ALU_OP_SRL = `ALU_OP_SRL,
		parameter ALU_OP_SRA = `ALU_OP_SRA,
		parameter ALU_OP_OR  = `ALU_OP_OR,
		parameter ALU_OP_AND = `ALU_OP_AND) 
	`else
		#(parameter ALU_OPWIDTH = 4, 
		parameter DATA_WIDTH = 32,
		parameter ALU_OP_ADD = 0,  // TODO: Separar en localparams
		parameter ALU_OP_SUB = 1,
		parameter ALU_OP_SLL = 2,
		parameter ALU_OP_SLT  = 3,
		parameter ALU_OP_SLTU = 4,
		parameter ALU_OP_XOR = 5,
		parameter ALU_OP_SRL = 6,
		parameter ALU_OP_SRA = 7,
		parameter ALU_OP_OR  = 8,
		parameter ALU_OP_AND = 9) 
	`endif
	(

	input [ALU_OPWIDTH-1:0]       ALU_op,
	input [DATA_WIDTH-1:0]      s1,
	input [DATA_WIDTH-1:0]      s2,
	output reg [DATA_WIDTH-1:0] d,
	output zero_o
	);

	wire [4:0] shift = s2[4:0];
	//reg [DATA_WIDTH-1:0] d;

	assign zero_o = (d == {DATA_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

	always @ *
		case(ALU_op)
			ALU_OP_ADD:  d = s1 + s2;               // Add s2 to s1 and place the result into d
			ALU_OP_SUB:  d = s1 - s2;               // Subtract s2 from s1 and place the result into d
			ALU_OP_SLL:  d = s1 << shift;			      // Shift s1 left by the by the lower 5 bits in s2 and place the result into d
			ALU_OP_SLT:  d = $signed(s1) < $signed(s2) ? {{DATA_WIDTH-1{1'b0}},1'b1} : 0;	// Set d to 1 if s1 is less than s2, otherwise set d to 0 (signed)
			ALU_OP_SLTU: d = s1 < s2 ? {{DATA_WIDTH-1{1'b0}},1'b1} : 0;			  // Set d to 1 if s1 is less than s2, otherwise set d to 0 (unsigned)
			ALU_OP_XOR:  d = s1 ^ s2;               // Set d to the bitwise XOR of s1 and s2
			ALU_OP_SRL:  d = s1 >> shift;			      // Shift s1 right by the by the lower 5 bits in s2 and place the result into d
			ALU_OP_SRA:  d = $signed(s1) >>> shift;// Shift s1 right by the by the lower 5 bits in s2 and place the result into d while retaining the sign
			ALU_OP_OR:   d = s1 | s2;               // Set d to the bitwise OR of s1 and s2
			ALU_OP_AND:  d = s1 & s2;               // Set d to the bitwise AND of s1 and s2
			default:   d = 0;
		endcase
endmodule

`default_nettype wire