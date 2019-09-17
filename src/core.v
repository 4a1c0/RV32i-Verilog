

`default_nettype none
`timescale 1ns/1ps


`include "src/defines.vh"
`include "src/dataMem.v"
`include "src/controlUnit.v"
`include "src/progMem.v"
`include "src/programCounter.v"
`include "src/regFile.v"
`include "src/execution_unit/executionUnit.v"
`include "src/multiplexer.v"



module core(
    clk,
    rst_n
    );
    
    parameter ADDR_WIDTH = 10;
    parameter DATA_WITDTH = 32;

    input 	clk;
    input 	rst_n;

    wire is_load_store; 
    wire we_dataMem;
    wire oe_DataMem;
    wire[ADDR_WIDTH-1 : 0] addr_DataMem;
    wire[DATA_WITDTH-1 : 0] data_DataMem;

    wire oe_progmem;
    wire[DATA_WITDTH-1 : 0] instruction_progmem;
    wire[ADDR_WIDTH-1 : 0] addr_progMem;

    wire [`ALU_OP_WIDTH-1:0] ALU_op_t;
    wire is_imm_t;
    wire [`MEM_DATA_WIDTH-1:0] imm_val_t;
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



    dataMem DataMem_inst (
        .rst_n		(rst_n)			,  // Reset Neg
        .we			(we_dataMem)	,  // Write Enable
        .oe			(oe_DataMem)	,  // Output Enable
        .clk		(clk)	,  // Chip Select
        .addr		(addr_DataMem)	,  // Address
        .data	(data_DataMem)  //  Data
    );

    progMem ProgMem_inst (
        .rst_n (rst_n)		,  // Reset Neg
        .clk (clk),             // Clk
        .oe (oe_progmem)		,  // Output Enable
        .addr (addr_progMem)		,  // Address
        .data_out (instruction_progmem)	   // Output Data
    );


    controlUnit controlUnit_inst(
        .instruction (instruction_progmem),
        .ALU_op (ALU_op_t),
        .is_imm (is_imm_t),  //execution unit imm
        .imm_val (imm_val_t),  //execution unit imm val 
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
        .addr (addr_progMem)
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
        .s1(rs1_reg_file),
        .s2(rs2_exec_unit_t),
        .d(data_in_reg_file),//data_in_reg_file),
        .is_branch(is_branch_t),
        .is_loadstore(is_load_store_t)
    );

    multiplexer2 mux2_exec_inst(
        .a(rs2_reg_file),
        .b(imm_val_t),
        .out(rs2_exec_unit_t),
        .select(is_imm_t)
    );


endmodule   
`default_nettype wire