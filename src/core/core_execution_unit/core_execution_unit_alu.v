`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

module alu (
  input [`ALU_OP_WIDTH-1:0]       ALU_op,
  input [`REG_DATA_WIDTH-1:0]      s1,
  input [`REG_DATA_WIDTH-1:0]      s2,
  output [`REG_DATA_WIDTH-1:0] d
            );
  wire [4:0] shift = s2[4:0];
  reg [`REG_DATA_WIDTH-1:0] d;
  always @ *
    case(ALU_op)
      `ALU_OP_ADD:  d = s1 + s2;               // Add s2 to s1 and place the result into d
      `ALU_OP_SUB:  d = s1 - s2;               // Subtract s2 from s1 and place the result into d
      `ALU_OP_SLL:  d = s1 << shift;			      // Shift s1 left by the by the lower 5 bits in s2 and place the result into d
      `ALU_OP_SLT:  d = $signed(s1) < $signed(s2) ? `REG_DATA_WIDTH'd1 : 0;	// Set d to 1 if s1 is less than s2, otherwise set d to 0 (signed)
      `ALU_OP_SLTU: d = s1 < s2 ? `REG_DATA_WIDTH'd1 : 0;			  // Set d to 1 if s1 is less than s2, otherwise set d to 0 (unsigned)
      `ALU_OP_XOR:  d = s1 ^ s2;               // Set d to the bitwise XOR of s1 and s2
      `ALU_OP_SRL:  d = s1 >> shift;			      // Shift s1 right by the by the lower 5 bits in s2 and place the result into d
      `ALU_OP_SRA:  d = $signed(s1) >>> shift;// Shift s1 right by the by the lower 5 bits in s2 and place the result into d while retaining the sign
      `ALU_OP_OR:   d = s1 | s2;               // Set d to the bitwise OR of s1 and s2
      `ALU_OP_AND:  d = s1 & s2;               // Set d to the bitwise AND of s1 and s2
      default:   d = 0;
    endcase
endmodule

`default_nettype wire