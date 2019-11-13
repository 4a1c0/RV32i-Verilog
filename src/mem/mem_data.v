`timescale 1ns/1ps

// TODO 1 sol stream de dades

`include "../defines.vh"

// Module Declaration
module dataMem(
        rst_n	,  // Reset Neg
        we		,  // Write Enable
        clk		,  // Clk
        addr	,  // Address
        data_in	,  // Input Data
        data_out,	   // Output Data
        write_transfer_i
    );

    parameter TRANSFER_WIDTH = 4;

    // Inputs
    input rst_n;
    input we;  
    input clk;  
    
    input [`MEM_ADDR_WIDTH-1:0]	addr;
    input [`MEM_DATA_WIDTH-1:0]	data_in;
    input [TRANSFER_WIDTH-1:0] write_transfer_i;

    output [`MEM_DATA_WIDTH-1:0] data_out;

    
    // Internal
    reg [`MEM_DATA_WIDTH-1:0] dataArray[0:`MEM_DEPTH-1];
    //reg [`MEM_DATA_WIDTH-1:0] data_out;
    //reg [`MEM_DATA_WIDTH-1:0] data ;
    
    // Code
    
    // Tristate output
    assign data_out = (we == 1'b0) ? dataArray[addr >> 2] : `MEM_DATA_WIDTH'b0;
    
    
    
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
        else if ( we  && |write_transfer_i && (addr >> 2) < `MEM_DEPTH) begin
            //dataArray[addr] <= data_in;
            if (write_transfer_i[0]) dataArray[addr >> 2][ 7: 0] <= data_in[ 7: 0];
            if (write_transfer_i[1]) dataArray[addr >> 2][15: 8] <= data_in[15: 8];
            if (write_transfer_i[2]) dataArray[addr >> 2][23:16] <= data_in[23:16];
            if (write_transfer_i[3]) dataArray[addr >> 2][31:24] <= data_in[31:24];
        end
        else if ( we  && !write_transfer_i && (addr >> 2) < `MEM_DEPTH) begin
            dataArray[addr >> 2] <= data_in;
        end
        // Read Operation
        // else if ( !we ) begin
        //     data_out <= dataArray[addr];
        // end
    end
    
    
endmodule