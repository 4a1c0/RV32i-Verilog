`timescale 1ns/1ps


`include "src/defines.vh"

// Module Declaration
module progMem(
        rst_n		,  // Reset Neg
        clk,             // Clk
        addr		,  // Address
        data_out	   // Output Data
    );

	
	// Inputs
	input rst_n; 
	input clk;
	
	input [`MEM_ADDR_WIDTH-1:0]	addr;
	
	// Outputs
	output [`MEM_DATA_WIDTH-1:0]	data_out;
	
	// Internal
	reg [`MEM_DATA_WIDTH-1:0] progArray[0:`MEM_DEPTH-1];
	reg [`MEM_DATA_WIDTH-1:0] data_out ;
	
	// Code
	
	// Tristate output
	//assign data_out = (cs && oe && !we) ? data_out : MEM_DATA_WIDTH'bz;
	

	// Read Operation (we = 0, oe = 1, cs = 1)
	always @ (posedge clk or negedge rst_n)
	begin : MEM_READ
		integer j;
		// Async Reset
		if ( !rst_n ) begin
			for (j=0; j < `MEM_DEPTH; j=j+1) begin
				progArray[j] <= 0; //reset array
			end
		end 
		else begin  // output enable logic supressed
			data_out = progArray[addr];
		end
	end
	
endmodule

	
	
	
 