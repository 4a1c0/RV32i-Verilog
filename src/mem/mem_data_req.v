`timescale 1ns/1ps

// TODO 1 sol stream de dades

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module dataMem
    `ifdef CUSTOM_DEFINE
		#(parameter ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `MEM_DATA_WIDTH,
        parameter MEM_DEPTH = `MEM_DEPTH,
        parameter TRANSFER_WIDTH = `MEM_TRANSFER_WIDTH) 
	`else
		#(parameter ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter MEM_DEPTH = 1 << ADDR_WIDTH-2,
        parameter TRANSFER_WIDTH = 4) 
	`endif(
        rst_n	,  // Reset Neg
        clk		,  // Clk
        we		,  // Write Enable
        addr	,  // Address
        data_in	,  // Input Data
        data_out,	   // Output Data
        write_transfer_i, // byte enable
        req_i,  // Request to make actiopn
        gnt_o,  // Action Granted //, wait until rvalid or cycle
        rvalid_o // Valid when write is ok // Write valid signal (OK to increase PC)


    );

    

    // Inputs
    input rst_n;
    input we;  
    input clk;  
    
    input [ADDR_WIDTH-1:0]	addr;
    input [DATA_WIDTH-1:0]	data_in;
    input [TRANSFER_WIDTH-1:0] write_transfer_i;

    output [DATA_WIDTH-1:0] data_out;

    input req_i;  // Request to make actiopn
    output gnt_o;  // Action Granted 
    output rvalid_o; // Valid when write is ok 

    
    // Internal
    reg [DATA_WIDTH-1:0] dataArray[0:MEM_DEPTH-1];
    reg [DATA_WIDTH-1:0] data_out;
    //reg [DATA_WIDTH-1:0] data ;
    reg gnt_o;  // Action Granted 
    reg rvalid_o; // Valid when write is ok
    
    // Code
    
    // Output
    //assign data_out = (we == 1'b0) ? dataArray[addr >> 2] : {DATA_WIDTH{1'b0}};

    
    always @ (posedge clk or negedge rst_n) begin : MEM
        integer j;
        // Async Reset
        if ( !rst_n ) begin 
            for (j=0; j < MEM_DEPTH; j=j+1) begin
                dataArray[j] <= 0; //reset array
            end
            `ifdef LOAD_MEMS
                // Load memory
                $readmemh("../../data/dataMem_h.mem", dataArray, 0, 3);
            `endif
            gnt_o <= 1'b0; 
            rvalid_o <= 1'b0;
        end 
        else if (!gnt_o && req_i) begin  //  
            gnt_o <= 1'b1;  // Action Granted 
            rvalid_o <= 1'b0;  // Reset write valid
            data_out <= {DATA_WIDTH{1'b0}};
        end
        else if (gnt_o) begin // When is granted
            gnt_o <= 1'b0;  // Reset the grant to prepare the next operation
            if ( we  && |write_transfer_i && (addr >> 2) < MEM_DEPTH) begin
                //dataArray[addr] <= data_in;
                if (write_transfer_i[0]) dataArray[addr >> 2][ 7: 0] <= data_in[ 7: 0];
                if (write_transfer_i[1]) dataArray[addr >> 2][15: 8] <= data_in[15: 8];
                if (write_transfer_i[2]) dataArray[addr >> 2][23:16] <= data_in[23:16];
                if (write_transfer_i[3]) dataArray[addr >> 2][31:24] <= data_in[31:24];
                rvalid_o <= 1'b1;  // Write Complete
            end
            else if ( we  && !write_transfer_i && (addr >> 2) < MEM_DEPTH) begin
                dataArray[addr >> 2] <= data_in;
                rvalid_o <= 1'b1;  // Write Complete
            end

            else if ( !we ) begin : MEM_READ
                data_out <= dataArray[addr];
            end
        end
        else data_out <= {DATA_WIDTH{1'b0}}; // Output 000 if no data 
    end
    
endmodule