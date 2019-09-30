

`default_nettype none
`timescale 1ns/1ps


`include "src/defines.vh"
`include "src/core/core_control_unit.v"
`include "src/core/core_program_counter.v"
`include "src/core/core_regfile.v"
`include "src/core/core_execution_unit/core_execution_unit.v"



module core(
    clk,
    rst_n,
    we_mem_data_o,
    addr_mem_data_o,
    val_mem_data_read_i,
    val_mem_data_write_o,
    addr_mem_prog_o,
    val_mem_prog_i
    );
    
    parameter ADDR_WIDTH = 10;
    parameter DATA_WIDTH = 32;

    input 	clk;
    input 	rst_n;

    output we_mem_data_o;
    output [ADDR_WIDTH-1 : 0] addr_mem_data_o;
    input [DATA_WIDTH-1 : 0] val_mem_data_read_i;
    output [DATA_WIDTH-1 : 0] val_mem_data_write_o;
    output [ADDR_WIDTH-1 : 0] addr_mem_prog_o;
    input [DATA_WIDTH-1 : 0] val_mem_prog_i;


    wire is_load_store; 
    //wire we_dataMem;
    //wire oe_DataMem;
    //wire[ADDR_WIDTH-1 : 0] addr_DataMem;
    //wire[DATA_WIDTH-1 : 0] data_DataMem;

    //wire oe_progmem;
    //wire[DATA_WIDTH-1 : 0] instruction_progmem;
    //wire[ADDR_WIDTH-1 : 0] addr_progMem;

    wire [`ALU_OP_WIDTH-1:0] ALU_op_t;
    wire [`LIS_OP_WIDTH-1:0] LIS_op_t;
    wire [`BR_OP_WIDTH-1:0] BR_op_t;
    wire [`DATA_ORIGIN_WIDTH-1:0] data_origin_t;
    wire is_load_store_t;
    wire is_branch_t;
    wire is_absolute_t;
    // wire is_conditional_t;
    //wire mem_w_t;
    wire mem_to_reg_t;
    //wire reg_r_t;
    wire [`REG_ADDR_WIDTH-1:0] r1_addr_t;
    wire [`REG_ADDR_WIDTH-1:0] r2_addr_t;
    wire [`REG_ADDR_WIDTH-1:0] reg_addr_t;
    wire [`REG_DATA_WIDTH-1:0] imm_val_t;

    wire we_reg_file;  
	wire [`REG_ADDR_WIDTH-1:0]	r1_num_read_reg_file;
	wire [`REG_ADDR_WIDTH-1:0]	r2_num_read_reg_file;
	wire [`REG_ADDR_WIDTH-1:0]	r_num_write_reg_file;
	
	wire [`REG_DATA_WIDTH-1:0]	data_in_reg_file;
	
	// Outputs
	wire [`REG_DATA_WIDTH-1:0]	rs1_reg_file;
	wire [`REG_DATA_WIDTH-1:0]	rs2_reg_file;



    wire [DATA_WIDTH-1 : 0] new_pc;




    controlUnit controlUnit_inst(
        .instruction (val_mem_prog_i),
        .ALU_op (ALU_op_t),
        .LIS_op (LIS_op_t),
        .BR_op_o (BR_op_t),
        .data_origin_o (data_origin_t),
        .is_branch_o (is_branch_t),        
        .is_load_store (is_load_store_t),  // execution_unit 
        .mem_w (we_mem_data_o),
        .mem_to_reg (mem_to_reg_t),
        .reg_r (we_reg_file),
        .r1_addr (r1_num_read_reg_file),
        .r2_addr (r2_num_read_reg_file),
        .reg_addr (r_num_write_reg_file),
        .imm_val_o (imm_val_t)  //execution unit imm val
    );

    programCounter program_counter_inst (
        .rst_n (rst_n),
        .clk (clk),
        .is_branch_i (is_branch_t),
        .is_absolute_i (is_absolute_t),
        .offset_i (new_pc[ADDR_WIDTH-1:0]),
        .addr (addr_mem_prog_o)
    );

    regFile reg_file_inst(
        .rst_n (rst_n)			,  // Reset Neg
        .clk	(clk)		,  // Clock
        .we (we_reg_file)			,  // Write Enable
        .r1_num_read (r1_num_read_reg_file)	,  // Address of r1 Read
        .r2_num_read (r2_num_read_reg_file)	,  // Address of r2 Read
        .r_num_write	(r_num_write_reg_file),  // Addres of Write Register
        .data_in	(data_in_reg_file)	,  // Data to write
        
        .rs1	(rs1_reg_file)   		,  // Output register 1
        .rs2	(rs2_reg_file)		   // Output register 2
    );

//assign data_in_reg_file = 32'h55555555;
    executionUnit exec_unit_inst(
        .ALU_op (ALU_op_t),
        .LIS_op (LIS_op_t),
        .BR_op (BR_op_t),
        .data_origin_i(data_origin_t),
        .rs1_i (rs1_reg_file),
        .rs2_i (rs2_reg_file),
        .imm_val_i (imm_val_t), // immidiate value
        .d_o (data_in_reg_file), // data_out_exec),//data_in_reg_file),
        .val_mem_data_write_o (val_mem_data_write_o),
        .val_mem_data_read_i (val_mem_data_read_i),
        .addr_mem_data_o (addr_mem_data_o),
        .is_branch_i (is_branch_t),
        .is_loadstore (is_load_store_t),
        .new_pc_offset_o (new_pc),
        .old_pc_i (addr_mem_prog_o),
        .is_absolute_o (is_absolute_t)
    );




endmodule   
`default_nettype wire