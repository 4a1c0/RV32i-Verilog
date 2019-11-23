`timescale 1ns/1ps


`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module progMem
	`ifdef CUSTOM_DEFINE
		#(parameter ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `MEM_DATA_WIDTH,
        parameter MEM_DEPTH = `MEM_DEPTH) 
	`else
		#(parameter ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter MEM_DEPTH = 1024) 
	`endif
	(
        rst_n		,  // Reset Neg
        clk,             // Clk
        addr		,  // Address
        data_out,	   // Output Data
        req_i,  // Request to make actiopn
        gnt_o,  // Action Granted 
        
    );

	
	// Inputs
	input rst_n; 
	input clk;
	
	input [ADDR_WIDTH-1:0]	addr;

	input req_i;  // Request to make actiopn
    
	
	// Outputs
	output reg [DATA_WIDTH-1:0] data_out;
	output gnt_o;  // Action Granted 
	
	// Internal
	reg [DATA_WIDTH-1:0] progArray[0:MEM_DEPTH-1];
	reg gnt_o;  // Action Granted 
	//reg [DATA_WIDTH-1:0] data_out ;  // Quartus
	
	// Code
	
	// Tristate output
	//assign data_out = (cs && oe && !we) ? data_out : MEM_DATA_WIDTH'bz;
	

	// Read Operation (we = 0, oe = 1, cs = 1)
	always @ (posedge clk or negedge rst_n) begin : MEM_READ
		integer j;
		// Async Reset
		if ( !rst_n ) begin
			for (j=0; j < MEM_DEPTH; j=j+1) begin
				progArray[j] <= 0; //reset array
			end
			`ifdef LOAD_MEMS
				// Load memory
				//$readmemb("../../data/programMem_b.mem", progArray, 0, 10);
				$readmemh("../../data/programMem_h.mem", progArray, 0, 24);
				//$readmemh("../../data/programMem_h_complete.mem", progArray, 0, 342);
			`endif
			gnt_o <= 1'b0; 
		end 
		else if (!gnt_o && req_i) begin  //  
            gnt_o <= 1'b1;  // Action Granted 
            data_out <= {DATA_WIDTH{1'b0}};
        end
        else if (gnt_o) begin // When is granted  // output enable logic supressed
			data_out = progArray[addr >> 2];
			gnt_o <= 1'b0;
		end
		else data_out <= {DATA_WIDTH{1'b0}}; // Output 000 if no data 
	end
endmodule
	
	
	
 