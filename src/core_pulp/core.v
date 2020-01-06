

`default_nettype none
`timescale 1ns/1ps


`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

`include "core_control_unit.v"
`include "core_program_counter.v"
`include "core_regfile.v"
`include "core_execution_unit/core_execution_unit.v"
`include "core_csr_unit/core_csr_unit.v"



module corep
    `ifdef CUSTOM_DEFINE
		#(parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter TRANSFER_WIDTH = `MEM_TRANSFER_WIDTH,
        parameter CSR_OP_WIDTH = `CSR_OP_WIDTH,
        parameter CSR_ADDR_WIDTH = `CSR_ADDR_WIDTH,
        parameter ALU_OP_WIDTH = `ALU_OP_WIDTH,
        parameter LIS_OP_WIDTH = `LIS_OP_WIDTH,
        parameter BR_OP_WIDTH = `BR_OP_WIDTH,
        parameter DATA_ORIGIN_WIDTH = `DATA_ORIGIN_WIDTH,
        parameter REG_ADDR_WIDTH = `REG_ADDR_WIDTH) 
	`else
		#(parameter MEM_ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter TRANSFER_WIDTH = 4,
        parameter CSR_OP_WIDTH = 3,  // 3
        parameter CSR_ADDR_WIDTH = 12,
        parameter ALU_OP_WIDTH = 4,
        parameter LIS_OP_WIDTH = 3,
        parameter BR_OP_WIDTH = 2,
        parameter DATA_ORIGIN_WIDTH = 2,
        parameter REG_ADDR_WIDTH = 5) 
	`endif
    (
        clk,
        rst_n,
        we_mem_data_o,
        addr_mem_data_o,
        val_mem_data_read_i,
        val_mem_data_write_o,
        req_mem_data_o,  // Request to make actiopn
        gnt_mem_data_i,  // Action Granted 
        rvalid_mem_data_i, // Valid when write is ok
        addr_mem_prog_o,
        val_mem_prog_i,
        req_mem_prog_o,  // Request to make actiopn
        gnt_mem_prog_i,  // Action Granted 
        write_transfer_mem_data_o
    );
    


    input 	clk;
    input 	rst_n;

    output we_mem_data_o;
    output [MEM_ADDR_WIDTH-1 : 0] addr_mem_data_o;
    input [DATA_WIDTH-1 : 0] val_mem_data_read_i;
    output [DATA_WIDTH-1 : 0] val_mem_data_write_o;
    output req_mem_data_o;  // Request to make actiopn
    input gnt_mem_data_i;  // Action Granted 
    input rvalid_mem_data_i; // Valid when write is ok // Write valid signal (OK to increase PC)
    output [MEM_ADDR_WIDTH-1 : 0] addr_mem_prog_o;
    input [DATA_WIDTH-1 : 0] val_mem_prog_i;
    output req_mem_prog_o;  // Request to make actiopn
    input gnt_mem_prog_i;  // Action Granted 

    output [TRANSFER_WIDTH-1:0] write_transfer_mem_data_o;

    wire is_stall_t;

    wire is_load_store; 
    //wire we_dataMem;
    //wire oe_DataMem;
    //wire[ADDR_WIDTH-1 : 0] addr_DataMem;
    //wire[DATA_WIDTH-1 : 0] data_DataMem;

    //wire oe_progmem;
    //wire[DATA_WIDTH-1 : 0] instruction_progmem;
    //wire[ADDR_WIDTH-1 : 0] addr_progMem;

    wire [ALU_OP_WIDTH-1:0] ALU_op_t;
    wire [LIS_OP_WIDTH-1:0] LIS_op_t;
    wire [BR_OP_WIDTH-1:0] BR_op_t;
    wire [DATA_ORIGIN_WIDTH-1:0] data_origin_t;
    wire is_load_store_t;
    wire is_branch_t;
    wire is_absolute_t;
    // wire is_conditional_t;
    //wire mem_w_t;
    //wire mem_to_reg_t;
    //wire reg_r_t;
    wire [REG_ADDR_WIDTH-1:0] r1_addr_t;
    wire [REG_ADDR_WIDTH-1:0] r2_addr_t;
    wire [REG_ADDR_WIDTH-1:0] reg_addr_t;
    wire [DATA_WIDTH-1:0] imm_val_t;

    wire we_reg_file;  
	wire [REG_ADDR_WIDTH-1:0]	r1_num_read_reg_file;
	wire [REG_ADDR_WIDTH-1:0]	r2_num_read_reg_file;
	wire [REG_ADDR_WIDTH-1:0]	r_num_write_reg_file;
	
	wire [DATA_WIDTH-1:0]	data_in_reg_file;
	
	// Outputs
	wire [DATA_WIDTH-1:0]	rs1_reg_file;
	wire [DATA_WIDTH-1:0]	rs2_reg_file;


    wire [DATA_WIDTH-1 : 0] pc;
    wire [DATA_WIDTH-1 : 0] new_pc;

    wire [CSR_ADDR_WIDTH-1 : 0]csr_addr_t;
    wire [CSR_OP_WIDTH-1 : 0] csr_op_t;
    wire [DATA_WIDTH-1 : 0] csr_val_r;
    wire [DATA_WIDTH-1 : 0] csr_val_w;

    reg req_mem_data_o;
    wire req_mem_data_o_intern;

    reg req_mem_prog_o;
    wire req_mem_prog_o_intern;

    assign addr_mem_prog_o = new_pc[MEM_ADDR_WIDTH-1:0]; // Assign lower bits of PC to prog ADDR


    controlUnit controlUnit_inst(
        .instruction (val_mem_prog_i),  // Instruction from prog mem input
        .ALU_op (ALU_op_t),  // ALU operation output
        .LIS_op (LIS_op_t),  // Load Store Operation output
        .BR_op_o (BR_op_t),  // Branch operation output
        .csr_op_o(csr_op_t),  // CSR OP
        .data_origin_o (data_origin_t),  // Data origin output (Rs2 or imm or pc)
        .is_branch_o (is_branch_t),  // Branch indicator output
        .is_load_store (is_load_store_t),  // execution_unit 
        .mem_w (we_mem_data_o),  // LoadStore indicator output
        .reg_w (we_reg_file),  // RegFile write enable
        .r1_addr (r1_num_read_reg_file),  // RS1 addr
        .r2_addr (r2_num_read_reg_file),  // RS2 addr
        .reg_addr (r_num_write_reg_file),  // RD addr
        .imm_val_o (imm_val_t),  //execution unit imm val
        .write_transfer_o (write_transfer_mem_data_o),
        .csr_addr_o(csr_addr_t),
        .is_stall_o(is_stall_t),
        .mem_req_o(req_mem_data_o_intern),  // Request to make actiopn
        .mem_gnt_i(gnt_mem_data_i),  // Action Granted //, wait until rvalid or cycle
        .mem_rvalid_i(rvalid_mem_data_i) // Valid when write is ok // Write valid signal (OK to increase PC)
    );

    programCounter program_counter_inst (
        .rst_n (rst_n),
        .clk (clk),
        //.is_branch_i (is_branch_t),  // Branch indicator
        //.is_absolute_i (is_absolute_t),  // Absolute or relative branch
        .is_stall_i(is_stall_t),  // Stall the PC
        .new_pc_i (new_pc),  // new pc or offset
        .pc (pc),  // next addr
        .req_mem_prog_o(req_mem_prog_o_intern),  // Request to make actiopn
        .gnt_mem_prog_i(gnt_mem_prog_i)  // Action Granted 
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

    executionUnit exec_unit_inst(
        .ALU_op (ALU_op_t),  // ALU operation input
        .LIS_op (LIS_op_t),  // Load Store Operation input
        .BR_op (BR_op_t),  // Branch operation input 
        .csr_op_i(csr_op_t),
        .data_origin_i(data_origin_t),  // Data origin input (Rs2 or imm or pc)
        .rs1_i (rs1_reg_file),  // RS1
        .rs2_i (rs2_reg_file),  // RS2
        .imm_val_i (imm_val_t), // immidiate value
        .d_o (data_in_reg_file),  // output data to data_in_reg_file),
        .val_mem_data_write_o (val_mem_data_write_o),  // output to data mem 
        .val_mem_data_read_i (val_mem_data_read_i),  // input from data mem
        .addr_mem_data_o (addr_mem_data_o),  // output address to data mem
        .is_branch_i (is_branch_t),  // Branch indicator input
        .is_loadstore (is_load_store_t),  // LoadStore indicator input
        .new_pc_offset_o (new_pc),  // new offset or new pc
        .old_pc_i (pc),  // Actual PC 
        //.is_absolute_o (is_absolute_t),  // Rewrite the current value to PC
        .csr_val_i(csr_val_r),  // CSR Val in READ
        .csr_val_o(csr_val_w)  // CSR Val Out WRITE
    );

    crs_unit crs_unit_inst(
        .rst_n(rst_n),
        .clk(clk),
        .csr_addr_i(csr_addr_t), // Adr 
        .csr_val_i(csr_val_w),  // Val in
        .csr_val_o(csr_val_r),  // Val Out
        .csr_op_i(csr_op_t)  // Op In
    );

    // Register the memory requests
    always @ (posedge clk or negedge rst_n) begin
        req_mem_data_o <= 1'b0;
        req_mem_prog_o <= 1'b0;
        if (!rst_n) begin
            req_mem_data_o <= 1'b0;
            req_mem_prog_o <= 1'b0;
        end
        else begin
            req_mem_data_o <= req_mem_data_o_intern;
            req_mem_prog_o <= req_mem_prog_o_intern;
        end
    end



endmodule   
`default_nettype wire