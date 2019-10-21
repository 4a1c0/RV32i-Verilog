`timescale 1ns/1ps
`default_nettype none
`include "src/defines.vh"

`include "src/core/core_csr_unit/core_csr_unit_timer.v"

// Module Declaration
module crs_unit (
    rst_n,
    clk,
    csr_addr_i,
    csr_val_i,
    csr_val_o,
    csr_op_i
    

    );

    parameter CSR_ADDR = 12;
    parameter CSR_OP_WIDTH = 3;
    parameter CSR_XLEN = 64;

    localparam CSRRW = 1;
    localparam CSRRS = 2;
    localparam CSRRC = 3;
    localparam CSRRWI = 4;
    localparam CSRRSI = 5;
    localparam CSRRCI = 6;

    localparam CYCLE_ADDR = 12'hC00;
    localparam CYCLEH_ADDR = 12'hC80;


    input rst_n;
    input clk;

    input [CSR_ADDR-1 : 0]csr_addr_i;
    input [`MEM_DATA_WIDTH-1 : 0] csr_val_i;
    output [`MEM_DATA_WIDTH-1 : 0] csr_val_o;
    input [CSR_OP_WIDTH-1 : 0] csr_op_i;

    wire [CSR_XLEN-1:0] timer_val_o;

    reg [`MEM_DATA_WIDTH-1 : 0] csr_val_o;

    reg [CSR_XLEN-1:0] cycle_csr; // core 
    reg [CSR_XLEN-1:0] time_csr;  // hart // TODO Alias of core
    reg [CSR_XLEN-1:0] instret_csr;  // number of instructions executed 

    reg [CSR_XLEN-1:0] csr_to_write;

    reg [CSR_XLEN-1:0] csr_o;

    timer timer_inst (
        .rst_n (rst_n),
        .clk (clk),
        .val_o (timer_val_o)
    );


    always @ (posedge clk or negedge rst_n) begin
		// Async Reset
		if ( !rst_n ) begin
			cycle_csr <= {CSR_XLEN{1'b0}}; //reset array
            instret_csr <= {CSR_XLEN{1'b0}}; //reset array
		end 
        else if (csr_op_i !== {CSR_OP_WIDTH{1'b0}}) begin 

            case(csr_op_i)
                CSRRW: begin  // CSRRW – for CSR reading and writing (CSR content is read to a destination register and source-register content is then copied to the CSR);
                    csr_to_write <= {{CSR_XLEN-32{1'b0}},csr_val_i};
                end
                CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                    
                end
                CSRRC:     ;  // CSRRC – for CSR reading and clearing (CSR content is read to the destination register and then its content is cleared according to the source register bit-mask);
                CSRRWI:     ;  // CSRRWI – the CSR content is read to the destination register and then the immediate constant is written into the CSR;
                CSRRSI: ;  // CSRRSI – the CSR content is read to the destination register and then set according to the immediate constant;
                CSRRCI:      ;  // CSRRCI – the CSR content is read to the destination register and then cleared according to the immediate constant;

            endcase

            case (csr_addr_i)
                CYCLE_ADDR: csr_o <= timer_val_o[31:0];
                CYCLEH_ADDR: csr_o <= timer_val_o[64:32];
                
            endcase
    
            
        end

	end

    
endmodule
`default_nettype wire