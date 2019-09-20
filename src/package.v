`default_nettype none
`timescale 1ns/1ps

`include "src/mem/mem_prog.v"
`include "src/mem/mem_data.v"
`include "src/core/core.v"

module package(
        clk,
        rst_n,
    );

    parameter ADDR_WIDTH = 10;
    parameter DATA_WITDTH = 32;

    input 	clk;
    input 	rst_n;

    wire we_mem_data;
    wire [ADDR_WIDTH-1 : 0] addr_mem_data;
    wire [DATA_WITDTH-1 : 0] val_mem_data_write;
    wire [DATA_WITDTH-1 : 0] val_mem_data_read;

    wire [ADDR_WIDTH-1 : 0] addr_mem_prog;
    wire [DATA_WITDTH-1 : 0] val_mem_prog;


core core_inst(
        .clk (clk),
        .rst_n (rst_n),
        .we_mem_data_o (we_mem_data),
        .addr_mem_data_o (addr_mem_data),
        .val_mem_data_read_i (val_mem_data_read),
        .val_mem_data_write_o (val_mem_data_write),
        .addr_mem_prog_o (addr_mem_prog),
        .val_mem_prog_i (val_mem_prog)
    );

dataMem mem_data_inst (
        .rst_n		(rst_n)			,  // Reset Neg
        .clk		(clk)	,
        .we			(we_mem_data)	,  // Write Enable
        .addr		(addr_mem_data)	,  // Address
        .data_in	(val_mem_data_write),  //  Data in
        .data_out   (val_mem_data_read)  //data out
    );

progMem mem_prog_inst (
        .rst_n (rst_n)		,  // Reset Neg
        .clk (clk),             // Clk
        .addr (addr_mem_prog)		,  // Address
        .data_out (val_mem_prog)	   // Output Data
    );

endmodule

`default_nettype wire