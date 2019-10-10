`timescale 1ns/1ps
`default_nettype none
`include "src/defines.vh"

// Module Declaration
module timer (
    rst_n,
    clk,
    val_o
    );

    parameter CSR_XLEN = 64;



    input rst_n;
    input clk;

    output [CSR_XLEN-1:0]val_o;

    reg [CSR_XLEN-1:0] val_o;  


    always @ (posedge clk or negedge rst_n) begin
		// Async Reset
		if ( !rst_n ) begin
			val_o <= {CSR_XLEN{1'b0}}; //reset 
		end 
        else begin
            val_o <= val_o + 1;
        end
	end

    
endmodule
`default_nettype wire