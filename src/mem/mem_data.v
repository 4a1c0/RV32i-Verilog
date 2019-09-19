`timescale 1ns/1ps

// TODO 1 sol stream de dades

`include "src/defines.vh"

// Module Declaration
module dataMem(
    rst_n	,  // Reset Neg
    we		,  // Write Enable
    clk		,  // Clk
    addr	,  // Address
    data_in	,  // Input Data
    data_out	   // Output Data
);
 
    
    
    
    // Inputs
    input rst_n;
    input we;  
    input clk;  
    
    input [`MEM_ADDR_WIDTH-1:0]	addr;
    input [`MEM_DATA_WIDTH-1:0]	data_in;

    output [`MEM_DATA_WIDTH-1:0] data_out;

    
    // Internal
    reg [`MEM_DATA_WIDTH-1:0] dataArray[0:`MEM_DEPTH-1];
    reg [`MEM_DATA_WIDTH-1:0] data_out;
    //reg [`MEM_DATA_WIDTH-1:0] data ;
    
    // Code
    
    // Tristate output
    //assign data_out = (cs && oe && !we) ? data_out : MEM_DATA_WIDTH'bz;
    
    
    
    always @ (posedge clk or negedge rst_n)
    begin : MEM_WRITE
        integer j;
        // Async Reset
        if ( !rst_n ) begin
            for (j=0; j < `MEM_DEPTH; j=j+1) begin
                dataArray[j] <= 0; //reset array
            end
        end 
        // Write Operation (we = 1, cs = 1)
        else if ( we ) begin
            dataArray[addr] <= data_in;
        end
        // Read Operation
        else if ( !we ) begin
            data_out <= dataArray[addr];
        end
    end
    
    
endmodule