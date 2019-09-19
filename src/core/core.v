

`default_nettype none
`timescale 1ns/1ps


`include "src/defines.vh"
`include "src/core/core_control_unit.v"
`include "src/core/core_program_counter.v"
`include "src/core/core_regfile.v"
`include "src/core/core_execution_unit/core_execution_unit.v"
`include "src/core/core_multiplexer2x32.v"



module core(
    clk,
    rst_n,
    we_mem_data_o,
    addr_mem_data_o,
    val_mem_data_i,
    val_mem_data_o,
    addr_mem_prog_o,
    val_mem_prog_i
    );
    
    parameter ADDR_WIDTH = 10;
    parameter DATA_WITDTH = 32;

    input 	clk;
    input 	rst_n;

    output we_mem_data_o;
    output [ADDR_WIDTH-1 : 0] addr_mem_data_o;
    input [DATA_WITDTH-1 : 0] val_mem_data_i;
    input [DATA_WITDTH-1 : 0] val_mem_data_o;
    output [ADDR_WIDTH-1 : 0] addr_mem_prog_o;
    input [DATA_WITDTH-1 : 0] val_mem_prog_i;


    wire is_load_store; 
    //wire we_dataMem;
    //wire oe_DataMem;
    //wire[ADDR_WIDTH-1 : 0] addr_DataMem;
    //wire[DATA_WITDTH-1 : 0] data_DataMem;

    //wire oe_progmem;
    //wire[DATA_WITDTH-1 : 0] instruction_progmem;
    //wire[ADDR_WIDTH-1 : 0] addr_progMem;

    wire [`ALU_OP_WIDTH-1:0] ALU_op_t;
    wire is_imm_rs2;
    wire [`MEM_DATA_WIDTH-1:0] imm_val_rs2;
    wire is_imm_rs1;
    wire [`MEM_DATA_WIDTH-1:0] imm_val_rs1;
    wire is_load_store_t;
    wire is_branch_t;
    wire mem_w_t;
    wire mem_r_t;
    wire mem_to_reg_t;
    //wire reg_r_t;
    wire [`REG_ADDR_WIDTH-1:0]r1_addr_t;
    wire [`REG_ADDR_WIDTH-1:0]r2_addr_t;
    wire [`REG_ADDR_WIDTH-1:0]reg_addr_t;

    wire we_reg_file;  
	wire [`REG_ADDR_WIDTH-1:0]	r1_num_read_reg_file;
	wire [`REG_ADDR_WIDTH-1:0]	r2_num_read_reg_file;
	wire [`REG_ADDR_WIDTH-1:0]	r_num_write_reg_file;
	
	wire [`REG_DATA_WIDTH-1:0]	data_in_reg_file;
	
	// Outputs
	wire [`REG_DATA_WIDTH-1:0]	rs1_reg_file;
	wire [`REG_DATA_WIDTH-1:0]	rs2_reg_file;


    wire [`REG_DATA_WIDTH-1:0]	rs2_exec_unit_t;
    wire [`REG_DATA_WIDTH-1:0]	rs1_exec_unit_t;


    controlUnit controlUnit_inst(
        .instruction (val_mem_prog_i),
        .pc_i (addr_mem_prog_o),
        .ALU_op (ALU_op_t),
        .is_imm_rs1_o(is_imm_rs1),  //execution unit imm rs1
        .imm_val_rs1_o(imm_val_rs1),  //execution unit imm val rs1
        .is_imm_rs2_o (is_imm_rs2),  //execution unit imm rs2
        .imm_val_rs2_o (imm_val_rs2),
        .is_load_store (is_load_store_t),  // execution_unit 
        .mem_w (mem_w_t),
        .mem_r (mem_r_t),
        .mem_to_reg (mem_to_reg_t),
        .reg_r (we_reg_file),
        .r1_addr (r1_num_read_reg_file),
        .r2_addr (r2_num_read_reg_file),
        .reg_addr (r_num_write_reg_file)
    );

    programCounter program_counter_inst (
        .rst_n (rst_n),
        .clk (clk),
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
        .ALU_op(ALU_op_t),
        .s1(rs1_exec_unit_t),
        .s2(rs2_exec_unit_t),
        .d(data_in_reg_file),//data_in_reg_file),
        .is_branch(is_branch_t),
        .is_loadstore(is_load_store_t)
    );

    multiplexer2 mux_rs1_exec_inst(
        .a(rs1_reg_file),
        .b(imm_val_rs1),
        .out(rs1_exec_unit_t),
        .select(is_imm_rs1)
    );

    multiplexer2 mux_rs2_exec_inst(
        .a(rs2_reg_file),
        .b(imm_val_rs2),
        .out(rs2_exec_unit_t),
        .select(is_imm_rs2)
    );




endmodule   
`default_nettype wire