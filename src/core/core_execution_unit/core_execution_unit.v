`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"
`include "src/core/core_execution_unit/core_execution_unit_alu.v" 
`include "src/core/core_execution_unit/core_execution_unit_lis.v" 
`include "src/core/core_execution_unit/core_execution_unit_br.v" 

module executionUnit(
		ALU_op,
		LIS_op,
		BR_op,
		data_origin_i,
		rs1_i,  // rs1
		rs2_i,  // rs2
		imm_val_i,  // in use to store a value and add the immidiate value
		d_o,
		is_branch_i,
		is_loadstore,
		val_mem_data_write_o,
		val_mem_data_read_i,
		addr_mem_data_o,
		old_pc_i,
		new_pc_offset_o,
		is_absolute_o
		);

	input [`ALU_OP_WIDTH-1:0]       ALU_op;
	input [`LIS_OP_WIDTH-1:0]       LIS_op;
	input [`BR_OP_WIDTH-1:0]        BR_op;
	input [`DATA_ORIGIN_WIDTH-1:0]        data_origin_i;

	input [`REG_DATA_WIDTH-1:0]      rs1_i;
	input [`REG_DATA_WIDTH-1:0]      rs2_i;
	input [`REG_DATA_WIDTH-1:0]      imm_val_i;
	output[`REG_DATA_WIDTH-1:0]      d_o;
    output[`REG_DATA_WIDTH-1:0]      val_mem_data_write_o;
    input [`REG_DATA_WIDTH-1:0]      val_mem_data_read_i;
    output[`MEM_ADDR_WIDTH-1:0]      addr_mem_data_o;
	output[`REG_DATA_WIDTH-1:0]      new_pc_offset_o;
	input [`MEM_ADDR_WIDTH-1:0]      old_pc_i;

	input       is_branch_i;
	input		is_loadstore;
	output		is_absolute_o;


    wire [`REG_DATA_WIDTH-1:0]      alu_o;
    wire [`REG_DATA_WIDTH-1:0]      mem_o;

	wire zero_alu_result;

	reg [`REG_DATA_WIDTH-1:0]      d_o;
	reg [`REG_DATA_WIDTH-1:0]      s2_ALU;
	reg [`REG_DATA_WIDTH-1:0]      s1_ALU;

	reg is_conditional;
	reg is_absolute_o;


    //assign d = (is_loadstore == 1'b0) ? alu_o : mem_o;  // mux at the end
	always @* begin
		is_conditional = 1'b0;
		is_absolute_o = 1'b0;

		if (is_branch_i === 1'b0) begin
			// Define Inputs
			case (data_origin_i)
				`REGS: begin
					s1_ALU = rs1_i;
					s2_ALU = rs2_i;
				end
				`RS2IMM_RS1: begin
					s1_ALU = rs1_i;
					s2_ALU = imm_val_i;
				end
				`RS2IMM_RS1PC: begin
					s1_ALU = old_pc_i;
					s2_ALU = imm_val_i;
				end
				
				default: begin
					s1_ALU = rs1_i;
					s2_ALU = rs2_i;
				end
			endcase
			// Define Outputs
			d_o = (is_loadstore === 1'b0) ? alu_o : mem_o;  // mux at the end
		end
		else if (is_branch_i === 1'b1) begin // in Branch condition
			// Define Inputs
			case (data_origin_i)
				`REGS: begin
					s1_ALU = rs1_i;
					s2_ALU = rs2_i;
					is_conditional = 1'b1;
					
				end
				`RS2IMM_RS1: begin
					s1_ALU = rs1_i;
					s2_ALU = imm_val_i;
					is_absolute_o = 1'b1;
				end
				`RS2IMM_RS1PC: begin
					s1_ALU = old_pc_i;
					s2_ALU = imm_val_i;
					is_absolute_o = 1'b1;
				end
				
				default: begin
					s1_ALU = rs1_i;
					s2_ALU = rs2_i;
					is_conditional = 1'b1;
				end
			endcase
			// Define Outputs
			d_o = { {`REG_DATA_WIDTH - `MEM_ADDR_WIDTH{1'b0}}, old_pc_i};
		end


	end

	//assign s2_ALU = (is_conditional_i == 1'b0)? s2: rs2;

	alu ALU (
		.ALU_op    (ALU_op),
		.s1        (s1_ALU),
		.s2        (s2_ALU),
		.d         (alu_o),
		.zero_o    (zero_alu_result)
	);

    lis LIS(
        .LIS_op (LIS_op),
        .val_mem_write_i (rs2_i),
        .val_mem_write_o(val_mem_data_write_o),
        .val_mem_read_i(val_mem_data_read_i),
        .val_mem_read_o(mem_o),
        .addr_mem_i(alu_o),
        .addr_mem_o(addr_mem_data_o)
    );

	br BR (
		.BR_op_i (BR_op),
		.alu_d (alu_o),
		.old_pc_i ({{`REG_DATA_WIDTH - `MEM_ADDR_WIDTH{1'b0}},old_pc_i}),
		.new_pc_i (imm_val_i),
		.new_pc_o (new_pc_offset_o),
		.is_conditional_i (is_conditional),
		.ALU_zero_i (zero_alu_result)
	);

endmodule

`default_nettype wire