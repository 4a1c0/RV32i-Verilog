// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include"tb/testbench.v"

module branch_test();

	tb TB();
	
	initial begin 

		//$dumpfile("vcd/riscV.vcd");
		//$dumpvars(0, TB.package_inst);

		
		
		TB.pc = 32'b0;

		// Initialize registers
		TB.clk = 1'b0;
		TB.rst_n = 1'b0;
		#100
		
		// Load memory
		$readmemb("data/programMem_b.mem", TB.package_inst.mem_prog_inst.progArray, 0, 3);
		$readmemh("data/dataMem_h.mem", TB.package_inst.mem_data_inst.dataArray, 0, 3);
		
		TB.test_jal;
		TB.rst_n = 1'b0;
		#100
		
		TB.test_and;
		TB.rst_n = 1'b0;
		#100

		TB.test_beq;
		TB.rst_n = 1'b0;
		#100

		

	$finish;
end

endmodule   