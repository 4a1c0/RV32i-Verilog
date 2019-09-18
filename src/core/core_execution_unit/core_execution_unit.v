`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"
`include "src/core/core_execution_unit/core_execution_unit_alu.v" 

module executionUnit(
    ALU_op,
    s1,
    s2,
    d,
    is_branch,
    is_loadstore
);

  input [`ALU_OP_WIDTH-1:0]       ALU_op;
  input [`REG_DATA_WIDTH-1:0]      s1;
  input [`REG_DATA_WIDTH-1:0]      s2;
  output[`REG_DATA_WIDTH-1:0]      d;

  input             is_branch;
  input		    is_loadstore;

  alu ALU (
    .ALU_op    (ALU_op),
    .s1        (s1),
    .s2        (s2),
    .d         (d)
  );

endmodule

`default_nettype wire