`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"
`include "src/core/core_execution_unit/core_execution_unit_alu.v" 
`include "src/core/core_execution_unit/core_execution_unit_lis.v" 
`include "src/core/core_execution_unit/core_execution_unit_br.v" 

module executionUnit(
		ALU_op,
		LIS_op,
		s1,
		s2,
		rs2,  // in use to store a value and add the immidiate value
		d,
		is_branch_i,
		is_loadstore,
		val_mem_data_write_o,
		val_mem_data_read_i,
		addr_mem_data_o,
		new_pc_o
		);

	input [`ALU_OP_WIDTH-1:0]       ALU_op;
	input [`LIS_OP_WIDTH-1:0]       LIS_op;
	input [`REG_DATA_WIDTH-1:0]      s1;
	input [`REG_DATA_WIDTH-1:0]      s2;
	input [`REG_DATA_WIDTH-1:0]      rs2;
	output[`REG_DATA_WIDTH-1:0]      d;
    output[`REG_DATA_WIDTH-1:0]      val_mem_data_write_o;
    input[`REG_DATA_WIDTH-1:0]      val_mem_data_read_i;
    output[`MEM_ADDR_WIDTH-1:0]      addr_mem_data_o;
	output[`REG_DATA_WIDTH-1:0]      new_pc_o;

	input       is_branch_i;
	input		is_loadstore;

    wire [`REG_DATA_WIDTH-1:0]      alu_o;
    wire [`REG_DATA_WIDTH-1:0]      mem_o;

	wire zero_alu_result;

	reg [`REG_DATA_WIDTH-1:0]      d;

    //assign d = (is_loadstore == 1'b0) ? alu_o : mem_o;  // mux at the end
	always @* begin
		if (is_branch_i == 1'b0) begin
			d = (is_loadstore == 1'b0) ? alu_o : mem_o;  // mux at the end
		end
		else d = s1;
	end

	alu ALU (
		.ALU_op    (ALU_op),
		.s1        (s1),
		.s2        (s2),
		.d         (alu_o),
		.zero_o    (zero_alu_result)
	);

    lis LIS(
        .LIS_op (LIS_op),
        .val_mem_write_i (rs2),
        .val_mem_write_o(val_mem_data_write_o),
        .val_mem_read_i(val_mem_data_read_i),
        .val_mem_read_o(mem_o),
        .addr_mem_i(alu_o),
        .addr_mem_o(addr_mem_data_o)
    );

	br BR (
		.zero_i (zero_alu_result),
		.old_pc_i (s1),
		.new_pc_i (alu_o),
		.new_pc_o (new_pc_o)
	);

endmodule

`default_nettype wire