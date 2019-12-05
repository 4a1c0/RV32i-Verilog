
`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif
`include "../pulp/ram_mux.v"
`include "core_pulp/core.v" 
`include "mem/mem_prog.v" 
`include "mem/mem_data.v" 
module top
#(parameter DATA_RAM_SIZE        = 1024,
parameter AXI_ADDR_WIDTH       = 32,
parameter AXI_DATA_WIDTH       = 32)
	(
        clk,
        rst_n
    );

    

    input 	clk;
    input 	rst_n;
 

localparam DATA_ADDR_WIDTH  = $clog2(DATA_RAM_SIZE);
localparam INSTR_ADDR_WIDTH = 10; 



    wire                        instr_mem_en;
  wire [INSTR_ADDR_WIDTH-1:0] core_instr_addr;
  wire                        instr_mem_we;
  wire [AXI_DATA_WIDTH/8-1:0] instr_mem_be;
  wire [AXI_DATA_WIDTH-1:0]   core_instr_rdata;
  wire [AXI_DATA_WIDTH-1:0]   instr_mem_wdata;

  //wire                        data_mem_en;
  wire [DATA_ADDR_WIDTH-1:0]  data_mem_addr;
  wire                        data_mem_we;
  wire [AXI_DATA_WIDTH/8-1:0] data_mem_be;
  wire [AXI_DATA_WIDTH-1:0]   data_mem_rdata;
  wire [AXI_DATA_WIDTH-1:0]   data_mem_wdata;

wire         core_data_req;
  wire         core_data_gnt;
  wire         core_data_rvalid;
  wire [9:0]  core_data_addr;
  wire         core_data_we;
  wire [3:0]   core_data_be;
  wire [31:0]  core_data_rdata;
  wire [31:0]  core_data_wdata;



core core_inst(
        .clk (clk),
        .rst_n (rst_n),
        .we_mem_data_o (core_data_we),
        .addr_mem_data_o (core_data_addr),
        .val_mem_data_read_i (core_data_rdata),
        .val_mem_data_write_o (core_data_wdata),
        .req_mem_data_o(core_data_req),  // Request to make actiopn
        .gnt_mem_data_i(core_data_gnt),  // Action Granted 
        .rvalid_mem_data_i(core_data_rvalid), // Valid when write is ok
        .write_transfer_mem_data_o (core_data_be),
        .addr_mem_prog_o (core_instr_addr),
        .val_mem_prog_i (core_instr_rdata)//,
        //.req_mem_prog_o(core_instr_req),  // Request to make actiopn
        //.gnt_mem_prog_i(core_instr_gnt)  // Action Granted 
        //.instr_rvalid_i  ( core_instr_rvalid ), Not used
        
    );

//   core RISCV_CORE
//       (
//         .clk           ( clk               ),
//         .rst_n          ( rst_n             ),

//         //.clock_en_i      ( clock_gating_i    ),
//         //.test_en_i       ( testmode_i        ),

//         //.boot_addr_i     ( boot_addr_i       ),
//         //.core_id_i       ( 4'h0              ),
//         //.cluster_id_i    ( 6'h0              ),

//         .instr_addr_o    ( core_instr_addr   ),
//         .instr_req_o     ( core_instr_req    ),
//         .instr_rdata_i   ( core_instr_rdata  ),
//         .instr_gnt_i     ( core_instr_gnt    ),
//         .instr_rvalid_i  ( core_instr_rvalid ),

//         .data_addr_o     ( core_lsu_addr     ),
//         .data_wdata_o    ( core_lsu_wdata    ),
//         .data_we_o       ( core_lsu_we       ),
//         .data_req_o      ( core_lsu_req      ),
//         .data_be_o       ( core_lsu_be       ),
//         .data_rdata_i    ( core_lsu_rdata    ),
//         .data_gnt_i      ( core_lsu_gnt      ),
//         .data_rvalid_i   ( core_lsu_rvalid   )
//         // .data_err_i      ( 1'b0              ),

//         // .irq_i           ( (|irq_i)          ),
//         // .irq_id_i        ( irq_id            ),
//         // .irq_ack_o       (                   ),
//         // .irq_id_o        (                   ),

//         // .debug_req_i     ( debug.req         ),
//         // .debug_gnt_o     ( debug.gnt         ),
//         // .debug_rvalid_o  ( debug.rvalid      ),
//         // .debug_addr_i    ( debug.addr        ),
//         // .debug_we_i      ( debug.we          ),
//         // .debug_wdata_i   ( debug.wdata       ),
//         // .debug_rdata_o   ( debug.rdata       ),
//         // .debug_halted_o  (                   ),
//         // .debug_halt_i    ( 1'b0              ),
//         // .debug_resume_i  ( 1'b0              ),

//         // .fetch_enable_i  ( fetch_enable_i    ),
//         // .core_busy_o     ( core_busy_o       ),
//         // .ext_perf_counters_i (               )
//       );


    
    ram_mux
    #(
        .ADDR_WIDTH ( DATA_ADDR_WIDTH ),
        .IN0_WIDTH  ( 32  ),
        .IN1_WIDTH  ( 32              ),
        .OUT_WIDTH  ( 32  )
    )
    data_ram_mux_i
    (
        .clk            ( clk              ),
        .rst_n          ( rst_n            ),

        .port0_req_i    (  1'b0     ),
        .port0_gnt_o    (                  ),
        .port0_rvalid_o (                  ),
        .port0_addr_i   (  10'd0                ),
        .port0_we_i     (  1'b0      ),
        .port0_be_i     (   4'd0     ),
        .port0_rdata_o  (      ),
        .port0_wdata_i  (   32'd0  ),

        .port1_req_i    ( core_data_req    ),
        .port1_gnt_o    ( core_data_gnt    ),
        .port1_rvalid_o ( core_data_rvalid ),
        .port1_addr_i   ( core_data_addr[DATA_ADDR_WIDTH-1:0] ),
        .port1_we_i     ( core_data_we     ),
        .port1_be_i     ( core_data_be     ),
        .port1_rdata_o  ( core_data_rdata  ),
        .port1_wdata_i  ( core_data_wdata  ),

        .ram_en_o       ( data_mem_en      ),
        .ram_addr_o     ( data_mem_addr    ),
        .ram_we_o       ( data_mem_we      ),
        .ram_be_o       ( data_mem_be      ),
        .ram_rdata_i    ( data_mem_rdata   ),
        .ram_wdata_o    ( data_mem_wdata   )
    );

    progMem mem_prog_inst (
        .rst_n (rst_n)		,  // Reset Neg
        .clk (clk),             // Clk
        .addr (core_instr_addr)		,  // Address
        .data_out (core_instr_rdata)	   // Output Data
    );

    dataMem mem_data_inst (
        .rst_n		(rst_n)			,  // Reset Neg
        .clk		(clk)	,
        .we			(data_mem_we)	,  // Write Enable
        .addr		(data_mem_addr)	,  // Address
        .data_in	(data_mem_wdata),  //  Data in
        .data_out   (data_mem_rdata),  //data out
        .write_transfer_i (data_mem_be) // write Byte mask
        //.req_i(req_mem_data_t),  // Request to make actiopn
        //.gnt_o(gnt_mem_data_t),  // Action Granted 
        //.rvalid_o(rvalid_mem_data_t) // Valid when write is ok
    );
    
endmodule

`default_nettype wire