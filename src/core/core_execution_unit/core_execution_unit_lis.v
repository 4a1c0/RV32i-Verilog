// Load-store moduele

`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

module lis (
        input [`ALU_OP_WIDTH-1:0]       LIS_op,
        input [`REG_DATA_WIDTH-1:0]      val_mem_write_i,
        output [`REG_DATA_WIDTH-1:0]      val_mem_write_o,
        input [`REG_DATA_WIDTH-1:0]      val_mem_read_i,
        output [`REG_DATA_WIDTH-1:0]      val_mem_read_o,
        input [`REG_DATA_WIDTH-1:0]      addr_mem_i,
        output [`MEM_ADDR_WIDTH-1:0]      addr_mem_o
    );

    assign addr_mem_o = addr_mem_i[`MEM_ADDR_WIDTH-1:0];

    reg [`REG_DATA_WIDTH-1:0]      val_mem_write_o;

	always @ *
		case(LIS_op)
			`ALU_OP_ADD:  val_mem_write_o = { {`REG_DATA_WIDTH - 8 {val_mem_write_i[7]}}, val_mem_write_i[7:0] };  // Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`ALU_OP_SUB:  val_mem_write_o = { {`REG_DATA_WIDTH - 16 {val_mem_write_i[15]}}, val_mem_write_i[15:0] };  // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`ALU_OP_SLL:  val_mem_write_o = val_mem_write_i;  // Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`ALU_OP_SLT:  val_mem_write_o = { {`REG_DATA_WIDTH - 8 {1'b0}}, val_mem_write_i[7:0] };	// Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			`ALU_OP_SLTU: val_mem_write_o = { {`REG_DATA_WIDTH - 8 {1'b0}}, val_mem_write_i[15:0] };   // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			default:   val_mem_write_o = 0;
		endcase
endmodule

`default_nettype wire