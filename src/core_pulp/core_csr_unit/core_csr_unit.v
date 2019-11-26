`timescale 1ns/1ps
`default_nettype none
`include "../../defines.vh"

`include "core_csr_unit_timer.v"

// Module Declaration
module crs_unit 
    `ifdef CUSTOM_DEFINE
		#(parameter CSR_XLEN = 64,
        parameter REG_XLEN = 32,
        parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter CSR_OP_WIDTH = `CSR_OP_WIDTH,
        parameter CSR_ADDR_WIDTH = `CSR_ADDR_WIDTH
        ) 
	`else
		#(parameter CSR_XLEN = 64,
        parameter REG_XLEN = 32,
        parameter CSR_OP_WIDTH = 3,  // 3
        parameter CSR_ADDR_WIDTH = 12
        ) 
	`endif
    (
        rst_n,
        clk,
        csr_addr_i, // Adr 
        csr_val_i,  // Val in
        csr_val_o,  // Val Out
        csr_op_i  // Op In
    );

    

    localparam CSRRW = 1;
    localparam CSRRS = 2;
    localparam CSRRC = 3;
    localparam CSRRWI = 4;
    localparam CSRRSI = 5;
    localparam CSRRCI = 6;

    localparam CYCLE_ADDR = 12'hC00;
    localparam CYCLEH_ADDR = 12'hC80;

    localparam TIME_ADDR = 12'hC01;
    localparam TIMEH_ADDR = 12'hC81;

    localparam INSTRET_ADDR = 12'hC02;
    localparam INSTRETH_ADDR = 12'hC82;


    input rst_n;
    input clk;

    input [CSR_ADDR_WIDTH-1 : 0]csr_addr_i;
    input [REG_XLEN-1 : 0] csr_val_i;
    output [REG_XLEN-1 : 0] csr_val_o;
    input [CSR_OP_WIDTH-1 : 0] csr_op_i;

    wire [CSR_XLEN-1:0] timer_val_i;
    reg  [CSR_XLEN-1:0] timer_val_o;
    reg timer_we_o;

    reg [REG_XLEN-1 : 0] csr_val_o;

    reg [CSR_XLEN-1:0] cycle_csr; // core 
    reg [CSR_XLEN-1:0] time_csr;  // hart // TODO Alias of core
    reg [CSR_XLEN-1:0] instret_csr;  // number of instructions executed 

    reg [REG_XLEN-1:0] csr_to_write;

    reg [CSR_XLEN-1:0] csr_o;

    timer timer_inst ( // Cycle, time and instret timer, because only one hart and unicycle core
        .rst_n (rst_n),
        .clk (clk),
        .val_o (timer_val_i),
        .val_i (timer_val_o),
        .we_i (timer_we_o)
    );


    always @ (posedge clk or negedge rst_n) begin
		// Async Reset
		if ( !rst_n ) begin
			//cycle_csr <= {CSR_XLEN{1'b0}}; //reset array
            //instret_csr <= {CSR_XLEN{1'b0}}; //reset array
            //csr_val_o <= {REG_XLEN{1'b0}};
            timer_val_o <= {REG_XLEN{1'b0}};
            timer_we_o <= 1'b0;
		end 
        else begin
            if (csr_op_i !== {CSR_OP_WIDTH{1'b0}}) begin 
                case (csr_addr_i) // CSR Addr
                    CYCLE_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[31:0];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [31:0] <= timer_val_i[31:0] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//
                    end
                    CYCLEH_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[63:32];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [63:32] <= timer_val_i[63:32] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//                   
                    end        
                    TIME_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[31:0];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [31:0] <= timer_val_i[31:0] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//
                    end
                    TIMEH_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[63:32];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [63:32] <= timer_val_i[63:32] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//                   
                    end
                    INSTRET_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[31:0];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [31:0] <= timer_val_i[31:0] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//
                    end
                    INSTRETH_ADDR: begin
                        //- For this address different actions -//
                        case(csr_op_i) // Operation Type
                            CSRRS: begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                                csr_val_o <= timer_val_i[63:32];
                                if (csr_val_i !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
                                    timer_we_o <= 1'b1;
                                    timer_val_o [63:32] <= timer_val_i[63:32] & csr_val_i ;
                                end
                            end
                            default: begin
                                $display("Ilegal CSR");  // TODO Throw interruption
                            end
                        endcase  // Operation Type
                        //--//                   
                    end
                endcase // CSR Addrs
            end
        end
	end

    // always@(csr_to_write) begin
    //     case (csr_addr_i)
    //         CYCLE_ADDR: begin
    //             csr_o <= timer_val_i[31:0];
    //             if (csr_to_write !== {REG_XLEN{1'b0}}) begin  // WARN Ilegal Operation
    //                 timer_we_o <= 1;
    //                 timer_val_o [31:0] <= csr_to_write;
    //             end
    //         end 
    //         CYCLEH_ADDR: begin
    //              csr_o <= timer_val_i[64:32];
    //              if (csr_to_write !== {REG_XLEN{1'b0}}) begin   // WARN Ilegal Operation
    //                 timer_we_o <= 1;
    //                 timer_val_o[64:32] <= csr_to_write;
    //             end
    //         end
    //     endcase
    // end

    
endmodule
`default_nettype wire