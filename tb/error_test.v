// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include"testbench.v"

module arithmeticologic_test();

	tb TB();
	
	initial begin 

		//$dumpfile("vcd/riscV.vcd");
		//$dumpvars(0, TB.top_inst);

		
		
		TB.pc = 32'b0;

		// Initialize registers
		TB.clk = 1'b0;
		TB.rst_n = 1'b0;
		#100
		
		// Load memory
		$readmemb("data/programMem_b.mem", TB.top_inst.mem_prog_inst.progArray, 0, 3);
		$readmemh("data/dataMem_h.mem", TB.top_inst.mem_data_inst.dataArray, 0, 3);
		TB.rst_n = 1'b1;
		#100

		TB.test_jal;


	$finish;
end

endmodule   