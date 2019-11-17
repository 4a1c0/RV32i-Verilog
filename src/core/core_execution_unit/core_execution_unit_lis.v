// Load-store moduele

`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
	`include "../../defines.vh"
`endif

module lis `ifdef CUSTOM_DEFINE
		#(parameter LIS_OP_WIDTH = `LIS_OP_WIDTH, 
		parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH,
		parameter LIS_LB = `LIS_LB,
        parameter LIS_LH = `LIS_LH,
        parameter LIS_LW = `LIS_LW,
        parameter LIS_LBU = `LIS_LBU,
        parameter LIS_LHU = `LIS_LHU,
        parameter LIS_SB = `LIS_SB,
        parameter LIS_SH = `LIS_SH,
        parameter LIS_SW = `LIS_SW) 
	`else
		#(parameter LIS_OP_WIDTH = 3, 
		parameter DATA_WIDTH = 32,
        parameter MEM_ADDR_WIDTH = 10,  // TODO: Separar en localparams
		parameter LIS_LB = 0,
        parameter LIS_LH = 1,
        parameter LIS_LW = 2,
        parameter LIS_LBU = 3,
        parameter LIS_LHU = 4,
        parameter LIS_SB = 5,
        parameter LIS_SH = 6,
        parameter LIS_SW = 7) 
	`endif
    (
        input [LIS_OP_WIDTH-1:0]       LIS_op,
        input [DATA_WIDTH-1:0]      val_mem_write_i,
        output reg [DATA_WIDTH-1:0]      val_mem_write_o,
        input [DATA_WIDTH-1:0]      val_mem_read_i,
        output reg [DATA_WIDTH-1:0]      val_mem_read_o,
        input [DATA_WIDTH-1:0]      addr_mem_i,
        output [MEM_ADDR_WIDTH-1:0]      addr_mem_o
    );

    assign addr_mem_o = addr_mem_i[MEM_ADDR_WIDTH-1:0];
    //assign val_mem_read_o = val_mem_read_i;

    //reg [DATA_WIDTH-1:0]      val_mem_read_o;  // Quartus
    //reg [DATA_WIDTH-1:0]      val_mem_write_o;  // Quartus


	always @ * begin
        val_mem_read_o = {DATA_WIDTH{1'b0}};
        val_mem_write_o = {DATA_WIDTH{1'b0}};
		case(LIS_op)
			LIS_LB:  val_mem_read_o = { {DATA_WIDTH - 8 {val_mem_read_i[7]}}, val_mem_read_i[7:0] };  // Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			LIS_LH:  val_mem_read_o = { {DATA_WIDTH - 16 {val_mem_read_i[15]}}, val_mem_read_i[15:0] };  // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			LIS_LW:  val_mem_read_o = val_mem_read_i;  // Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd
			LIS_LBU:  val_mem_read_o = { {DATA_WIDTH - 8 {1'b0}}, val_mem_read_i[7:0] };	// Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			LIS_LHU: val_mem_read_o = { {DATA_WIDTH - 16 {1'b0}}, val_mem_read_i[15:0] };   // Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd
			LIS_SB: val_mem_write_o = { {DATA_WIDTH - 8 {1'b0}}, val_mem_write_i[7:0] };  // sb         "Store 8-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
            LIS_SH: val_mem_write_o = { {DATA_WIDTH - 16 {1'b0}}, val_mem_write_i[15:0] };  // sh         "Store 16-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
            LIS_SW: val_mem_write_o = val_mem_write_i;  // sw         "Store 32-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
            default: begin
                val_mem_read_o = {DATA_WIDTH{1'b0}};
                val_mem_write_o = {DATA_WIDTH{1'b0}};
            end
		endcase
    end
endmodule

`default_nettype wire