`timescale 1ns/1ps


`include "src/defines.vh"

// Module Declaration
module regFile(
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

	
	input [`REG_ADDR_WIDTH-1:0]	r1_num_read;
	input [`REG_ADDR_WIDTH-1:0]	r2_num_read;
	input [`REG_ADDR_WIDTH-1:0]	r_num_write;
	
	input [`REG_DATA_WIDTH-1:0]	data_in;
	
	// Outputs
	output [`REG_DATA_WIDTH-1:0]	rs1;
	output [`REG_DATA_WIDTH-1:0]	rs2;
	
	// Internal
	reg [`REG_DATA_WIDTH-1:0] regFile[0:`REG_DEPTH-1];
	
	// Code

	
	assign rs1 = (r1_num_read == `REG_ADDR_WIDTH'd0) ? `REG_DATA_WIDTH'd0 : regFile[r1_num_read];
	

		
	always @ (posedge clk or negedge rst_n)
	begin : MEM_WRITE
	integer j;
		// Async Reset
		if ( !rst_n ) begin
			for (j=0; j < `REG_DEPTH; j=j+1) begin
				regFile[j] <= 0; //reset array
			end
		end 
		// Write Operation (we = 1, cs = 1)
		else if ( we ) begin
			regFile[r_num_write] <= data_in;
		end
	end
	
endmodule

	
	
	
 