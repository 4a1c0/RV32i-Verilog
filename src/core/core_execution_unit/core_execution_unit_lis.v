// Load-store moduele

`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

module lis (
        input [`LIS_OP_WIDTH-1:0]       LIS_op,
        input [`REG_DATA_WIDTH-1:0]      val_mem_write_i,
        output [`REG_DATA_WIDTH-1:0]      val_mem_write_o,
        input [`REG_DATA_WIDTH-1:0]      val_mem_read_i,
        output [`REG_DATA_WIDTH-1:0]      val_mem_read_o,
        input [`REG_DATA_WIDTH-1:0]      addr_mem_i,
        output [`MEM_ADDR_WIDTH-1:0]      addr_mem_o
    );

    assign addr_mem_o = addr_mem_i[`MEM_ADDR_WIDTH-1:0];
    //assign val_mem_read_o = val_mem_read_i;

    reg [`REG_DATA_WIDTH-1:0]      val_mem_write_o;
    reg [`REG_DATA_WIDTH-1:0]      val_mem_read_o;

	always @ *
		case(LIS_op)
			`LIS_LB:  val_mem_read_o = { {`REG_DATA_WIDTH - 8 {val_mem_read_i[7]}}, val_mem_read_i[7:0] };  // Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`LIS_LH:  val_mem_read_o = { {`REG_DATA_WIDTH - 16 {val_mem_read_i[15]}}, val_mem_read_i[15:0] };  // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`LIS_LW:  val_mem_read_o = val_mem_read_i;  // Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			`LIS_LBU:  val_mem_read_o = { {`REG_DATA_WIDTH - 8 {1'b0}}, val_mem_read_i[7:0] };	// Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			`LIS_LHU: val_mem_read_o = { {`REG_DATA_WIDTH - 8 {1'b0}}, val_mem_read_i[15:0] };   // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			default:   val_mem_read_o = 0;
		endcase
endmodule

`default_nettype wire