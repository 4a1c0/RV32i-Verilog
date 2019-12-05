`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

`include "mem/mem_prog.v"
`include "mem/mem_data.v"
`include "core/core.v"


module top
    `ifdef CUSTOM_DEFINE
		#(parameter ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter TRANSFER_WIDTH = `MEM_TRANSFER_WIDTH) 
	`else
		#(parameter ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter TRANSFER_WIDTH = 4) 
	`endif
	(
        clk,
        rst_n
    );

    

    input 	clk;
    input 	rst_n;

    wire we_mem_data;
    wire [ADDR_WIDTH-1 : 0] addr_mem_data;
    wire [DATA_WIDTH-1 : 0] val_mem_data_write;
    wire [DATA_WIDTH-1 : 0] val_mem_data_read;

    wire [ADDR_WIDTH-1 : 0] addr_mem_prog;
    wire [DATA_WIDTH-1 : 0] val_mem_prog;

    wire  [TRANSFER_WIDTH-1:0] write_transfer;

    wire req_mem_data_t;
    wire gnt_mem_data_t;
    wire rvalid_mem_data_t;


core core_inst(
        .clk (clk),
        .rst_n (rst_n),
        .we_mem_data_o (we_mem_data),
        .addr_mem_data_o (addr_mem_data),
        .val_mem_data_read_i (val_mem_data_read),
        .val_mem_data_write_o (val_mem_data_write),
        //.req_mem_data_o(req_mem_data_t),  // Request to make actiopn
        //.gnt_mem_data_i(gnt_mem_data_t),  // Action Granted 
        //.rvalid_mem_data_i(rvalid_mem_data_t), // Valid when write is ok
        .addr_mem_prog_o (addr_mem_prog),
        .val_mem_prog_i (val_mem_prog),
        .write_transfer_mem_data_o (write_transfer)
    );

dataMem mem_data_inst (
        .rst_n		(rst_n)			,  // Reset Neg
        .clk		(clk)	,
        .we			(we_mem_data)	,  // Write Enable
        .addr		(addr_mem_data)	,  // Address
        .data_in	(val_mem_data_write),  //  Data in
        .data_out   (val_mem_data_read),  //data out
        .write_transfer_i (write_transfer) // write Byte mask
        //.req_i(req_mem_data_t),  // Request to make actiopn
        //.gnt_o(gnt_mem_data_t),  // Action Granted 
        //.rvalid_o(rvalid_mem_data_t) // Valid when write is ok
    );

progMem mem_prog_inst (
        .rst_n (rst_n)		,  // Reset Neg
        .clk (clk),             // Clk
        .addr (addr_mem_prog)		,  // Address
        .data_out (val_mem_prog)	   // Output Data
    );

endmodule

`default_nettype wire