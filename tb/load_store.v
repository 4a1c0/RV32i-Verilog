// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include"tb/testbench.v"

module load_store_test();
	
		reg          clk            ;
		reg          rst_n          ;

		reg [31:0] instruction;
		reg [31:0] pc;
		reg [31:0] rd;
		reg [31:0] expectedResult;

	
	package package_inst(
		.clk				(clk),
		.rst_n				(rst_n)
	);

	always #50 clk = !clk;
	initial begin 

		$dumpfile("vcd/riscV.vcd");
		$dumpvars(0, package_inst);
		// Load memory
		$readmemb("data/programMem_b.mem", package_inst.mem_prog_inst.progArray, 0, 3);
		$readmemh("data/dataMem_h.mem", package_inst.mem_data_inst.dataArray, 0, 3);
		
		pc = 32'b0;

		// Initialize registers
		clk = 1'b0;
		rst_n = 1'b0;
		#100
		

        //tb.test_load;

		rst_n		= 1'b1;
		#500
		//forever #10 clk = ~clk; // generate a clock
		$finish;
	end





always @ (negedge clk) begin
		// $display("reg5 = %d\npc = %d\ninst = %b", package_inst.reg_file_inst.regFile[5], package_inst.addr_progMem, package_inst.instruction_progmem);
		$display("reg6 = %d", package_inst.core_inst.reg_file_inst.regFile[6]);
		// $display("rs2_exec_unit_t = %d", package_inst.rs2_exec_unit_t);
		// $display("ALU_op_t = %d", package_inst.ALU_op_t);
		//$display("is_imm_t = %d", package_inst.is_imm_t);
		// $display("r_num_write_reg_file = %d", package_inst.r_num_write_reg_file);

end

endmodule   