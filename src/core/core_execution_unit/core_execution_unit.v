`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
	`include "../../defines.vh"
`endif

`include "core_execution_unit_alu.v" 
`include "core_execution_unit_lis.v" 
`include "core_execution_unit_br.v" 

module executionUnit
	`ifdef CUSTOM_DEFINE
		#(parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter ALU_OP_WIDTH = `ALU_OP_WIDTH,
        parameter LIS_OP_WIDTH = `LIS_OP_WIDTH,
        parameter BR_OP_WIDTH = `BR_OP_WIDTH,
        parameter DATA_ORIGIN_WIDTH = `DATA_ORIGIN_WIDTH,
		parameter REGS = `REGS,  // TODO: Separar en localparams
		parameter RS2IMM_RS1 = `RS2IMM_RS1,
		parameter RS2IMM_RS1PC = `RS2IMM_RS1PC) 
	`else
		#(parameter MEM_ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter ALU_OP_WIDTH = 4,
        parameter LIS_OP_WIDTH = 3,
        parameter BR_OP_WIDTH = 2,
        parameter DATA_ORIGIN_WIDTH = 2,
		parameter REGS = 0,  // TODO: Separar en localparams
		parameter RS2IMM_RS1 = 1,
		parameter RS2IMM_RS1PC = 2) 
	`endif
	(
		ALU_op,
		LIS_op,
		BR_op,
		data_origin_i,
		data_target_i,
		rs1_i,  // rs1
		rs2_i,  // rs2
		imm_val_i,  // in use to store a value and add the immidiate value
		d_o,
		is_branch_i,
		//is_loadstore,
		val_mem_data_write_o,
		val_mem_data_read_i,
		addr_mem_data_o,
		pc_i,
		new_pc_offset_o,
		is_conditional_i,
        //csr_val_o,
        csr_val_i
    );
	// DATA TARGET
	localparam DATA_TARGET_WIDTH = 2;
	localparam DATA_TARGET_ALU_O = 0; //{DATA_TARGET_WIDTH{1'b0}};
	localparam DATA_TARGET_MEM_WR = 1;
	localparam DATA_TARGET_PC_4 = 2;
	localparam DATA_TARGET_CSR = 3;


	input [ALU_OP_WIDTH-1:0]       ALU_op;
	input [LIS_OP_WIDTH-1:0]       LIS_op;
	input [BR_OP_WIDTH-1:0]        BR_op;
	input [DATA_ORIGIN_WIDTH-1:0]  data_origin_i;
	input [DATA_TARGET_WIDTH-1:0]  data_target_i;

	input [DATA_WIDTH-1:0]      rs1_i;
	input [DATA_WIDTH-1:0]      rs2_i;
	input [DATA_WIDTH-1:0]      imm_val_i;
	output[DATA_WIDTH-1:0]      d_o;
    output[DATA_WIDTH-1:0]      val_mem_data_write_o;
    input [DATA_WIDTH-1:0]      val_mem_data_read_i;
    output[MEM_ADDR_WIDTH-1:0]      addr_mem_data_o;
	output[DATA_WIDTH-1:0]      new_pc_offset_o;
	input [DATA_WIDTH-1:0]      pc_i;

    input [DATA_WIDTH-1 : 0] csr_val_i;
    //output [DATA_WIDTH-1 : 0] csr_val_o;

	input       is_branch_i;
	//input		is_loadstore;
	input	 	is_conditional_i;
	//output		is_absolute_o;

	wire [DATA_WIDTH-1:0]      pc_4;

    wire [DATA_WIDTH-1:0]      alu_o;
    wire [DATA_WIDTH-1:0]      mem_o;

	wire zero_alu_result;

	reg [DATA_WIDTH-1:0]      d_o;
	reg [DATA_WIDTH-1:0]      s2_ALU;
	reg [DATA_WIDTH-1:0]      s1_ALU;

    //reg [DATA_WIDTH-1 : 0] csr_val_o;

	//reg is_conditional;
	//reg is_absolute_o;


    //assign d = (is_loadstore == 1'b0) ? alu_o : mem_o;  // mux at the end
	always @* begin
		// is_conditional = 1'b0;
		// is_absolute_o = 1'b0;
		s1_ALU = {DATA_WIDTH{1'b0}};
		s2_ALU = {DATA_WIDTH{1'b0}};
		// csr_val_o = {DATA_WIDTH{1'b0}};
		d_o = {DATA_WIDTH{1'b0}};

		case (data_origin_i)
			REGS: begin
				s1_ALU = rs1_i;
				s2_ALU = rs2_i;
				//is_conditional = 1'b1;
			end
			RS2IMM_RS1: begin
				s1_ALU = rs1_i;
				s2_ALU = imm_val_i;
			end
			RS2IMM_RS1PC: begin
				s1_ALU = pc_i;
				s2_ALU = imm_val_i;
			end
			
			default: begin
				s1_ALU = rs1_i;
				s2_ALU = rs2_i;
			end
		endcase

		case (data_target_i) 
			DATA_TARGET_ALU_O: begin
				d_o = alu_o;
			end
			DATA_TARGET_MEM_WR: begin
				d_o = mem_o;
			end
			DATA_TARGET_PC_4: begin
				d_o = pc_4; // Instruction PC + 4
			end
			DATA_TARGET_CSR: begin
				d_o = csr_val_i;
			end
		endcase

		// if (csr_op_i != 3'b0 ) begin
        //     if (csr_op_i === CSRRW || csr_op_i === CSRRS || csr_op_i === CSRRC) csr_val_o = rs1_i;
        //     else if (csr_op_i === CSRRWI || csr_op_i === CSRRSI || csr_op_i === CSRRCI) csr_val_o = imm_val_i;
		// 	else csr_val_o = {DATA_WIDTH{1'b0}};
		// end



		// if (is_branch_i === 1'b0 && csr_op_i === 3'b0 ) begin
		// 	// Define Inputs
		// 	case (data_origin_i)
		// 		REGS: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = rs2_i;
		// 		end
		// 		RS2IMM_RS1: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = imm_val_i;
		// 		end
		// 		RS2IMM_RS1PC: begin
		// 			s1_ALU = reg_pc_i;
		// 			s2_ALU = imm_val_i;
		// 		end
				
		// 		default: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = rs2_i;
		// 		end
		// 	endcase
		// 	// Define Outputs
		// 	d_o = (is_loadstore === 1'b0) ? alu_o : mem_o;  // mux at the end
		// end
		// else if (is_branch_i === 1'b1) begin // in Branch condition
		// 	// Define Inputs
		// 	case (data_origin_i)
		// 		REGS: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = rs2_i;
		// 			is_conditional = 1'b1;
					
		// 		end
		// 		RS2IMM_RS1: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = imm_val_i;
		// 			// is_absolute_o = 1'b1;
		// 		end
		// 		RS2IMM_RS1PC: begin
		// 			s1_ALU = reg_pc_i;
		// 			s2_ALU = imm_val_i;
		// 			// is_absolute_o = 1'b1;
		// 		end
				
		// 		default: begin
		// 			s1_ALU = rs1_i;
		// 			s2_ALU = rs2_i;
		// 			is_conditional = 1'b1;
		// 		end
		// 	endcase
		// 	// Define Outputs
		// 	d_o = {pc_i}; // Insytruction PC + 4
		// end 
        // else if (csr_op_i != 3'b0 ) begin
        //     if (csr_op_i === CSRRW || csr_op_i === CSRRS || csr_op_i === CSRRC) csr_val_o = rs1_i;
        //     else if (csr_op_i === CSRRWI || csr_op_i === CSRRSI || csr_op_i === CSRRCI) csr_val_o = imm_val_i;
		// 	else csr_val_o = {DATA_WIDTH{1'b0}};
        //     // Define Outputs
        //     d_o = csr_val_i;
		// end



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
		.is_branch_i(is_branch_i),
		.BR_op_i (BR_op),
		.alu_d (alu_o),
		.pc_4_o (pc_4),
		.pc_i (pc_i),
		.imm_i (imm_val_i),
		.new_pc_o (new_pc_offset_o),
		.is_conditional_i (is_conditional_i),
		.ALU_zero_i (zero_alu_result)
	);



endmodule

`default_nettype wire