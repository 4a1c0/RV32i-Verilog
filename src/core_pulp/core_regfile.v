`timescale 1ns/1ps


`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module regFile
	`ifdef CUSTOM_DEFINE
		#(parameter DATA_WIDTH = `REG_DATA_WIDTH,
		parameter REG_DEPTH = `REG_DEPTH,
        parameter REG_ADDR_WIDTH = `REG_ADDR_WIDTH) 
	`else
		#(parameter DATA_WIDTH = 32,
		parameter REG_DEPTH = 32,
        parameter REG_ADDR_WIDTH = 5) 
	`endif(
	rst_n			,  // Reset Neg
	clk			,  // Clock
	we			,  // Write Enable
	r1_num_read	,  // Address of r1 Read
	r2_num_read	,  // Address of r2 Read
	r_num_write	,  // Addres of Write Register
	data_in		,  // Data to write
	
	rs1	   		,  // Output register 1
	rs2			   // Output register 2
);
	

	
	// Inputs
	input rst_n; 
	input clk; 
	input we;  

	
	input [REG_ADDR_WIDTH-1:0]	r1_num_read;
	input [REG_ADDR_WIDTH-1:0]	r2_num_read;
	input [REG_ADDR_WIDTH-1:0]	r_num_write;
	
	input [DATA_WIDTH-1:0]	data_in;
	
	// Outputs
	output [DATA_WIDTH-1:0]	rs1;
	output [DATA_WIDTH-1:0]	rs2;
	
	// Internal
	reg [DATA_WIDTH-1:0] regFile[0:REG_DEPTH-1];

	
	// Code

	
	assign rs1 = (r1_num_read == {REG_ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : regFile[r1_num_read];
	assign rs2 = (r2_num_read == {REG_ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : regFile[r2_num_read];
	

		
	always @ (posedge clk or negedge rst_n) begin : REG
		integer j;
		// Async Reset
		if ( !rst_n ) begin
			for (j=0; j < REG_DEPTH; j=j+1) begin
				regFile[j] <= {DATA_WIDTH{1'b0}}; //reset array
			end
		end 
		// Write Operation (we = 1, cs = 1)
		else if ( we ) begin
			regFile[r_num_write] <= data_in;
		end

	end
	
endmodule

	
	
	
 