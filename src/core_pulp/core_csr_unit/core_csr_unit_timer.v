`timescale 1ns/1ps
`default_nettype none
`include "../../defines.vh"

// Module Declaration
module timer (
    rst_n,
    clk,
    val_o,
    we_i,
    val_i
    );

    parameter CSR_XLEN = 64;



    input rst_n;
    input clk;

    input we_i;

    output [CSR_XLEN-1:0] val_o;
    input [CSR_XLEN-1:0] val_i;

    reg [CSR_XLEN-1:0] val_o; 


    always @ (posedge clk or negedge rst_n) begin
		// Async Reset
		if ( !rst_n ) begin
			val_o <= {CSR_XLEN{1'b0}}; //reset 
		end 
        else if (we_i === 1'b0) begin
            val_o <= val_o + 1;
        end
        else if (we_i === 1'b1) begin
            val_o <= val_i;
        end
	end

    
endmodule
`default_nettype wire