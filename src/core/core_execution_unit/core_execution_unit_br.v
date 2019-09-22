// Branching moduele

`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

module br (
        input zero_i,
        input [`REG_DATA_WIDTH-1:0] old_pc_i,
        output [`REG_DATA_WIDTH-1:0] new_pc_o,
        input [`REG_DATA_WIDTH-1:0] new_pc_i
    );

    assign new_pc_o = new_pc_i;

endmodule