`default_nettype none
`timescale 1ns/1ps

`include "mem/mem_prog.v"
`include "mem/mem_data.v"
`include "core/core.v"

module top(
        clk,
        rst_n,
    );

    parameter ADDR_WIDTH = 10;
    parameter DATA_WITDTH = 32;
    parameter TRANSFER_WIDTH = 4;

    input 	clk;
    input 	rst_n;

    wire we_mem_data;
    wire [ADDR_WIDTH-1 : 0] addr_mem_data;
    wire [DATA_WITDTH-1 : 0] val_mem_data_write;
    wire [DATA_WITDTH-1 : 0] val_mem_data_read;

    wire [ADDR_WIDTH-1 : 0] addr_mem_prog;
    wire [DATA_WITDTH-1 : 0] val_mem_prog;

    wire  [TRANSFER_WIDTH-1:0] write_transfer;


core core_inst(
        .clk (clk),
        .rst_n (rst_n),
        .we_mem_data_o (we_mem_data),
        .addr_mem_data_o (addr_mem_data),
        .val_mem_data_read_i (val_mem_data_read),
        .val_mem_data_write_o (val_mem_data_write),
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
    );

progMem mem_prog_inst (
        .rst_n (rst_n)		,  // Reset Neg
        .clk (clk),             // Clk
        .addr (addr_mem_prog)		,  // Address
        .data_out (val_mem_prog)	   // Output Data
    );

endmodule

`default_nettype wire