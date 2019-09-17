// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include "src/defines.vh"

`include"src/core.v"

module tb();
	
		reg          clk            ;
		reg          rst_n          ;

		reg [31:0] instruction;
		reg [31:0] pc;
		reg [31:0] rd;
		reg [31:0] expectedResult;

	
	core Core_inst(
		.clk				(clk),
		.rst_n				(rst_n)
	);

	always #50 clk = !clk;
	initial begin 

		$dumpfile("vcd/riscV.vcd");
		$dumpvars(0, Core_inst);
		// Load memory
		$readmemb("data/programMem_b.mem", Core_inst.ProgMem_inst.progArray, 0, 3);
		$readmemh("data/dataMem_h.mem", Core_inst.DataMem_inst.dataArray, 0, 3);
	 
		// Initialize registers
		clk = 1'b0;
		rst_n = 1'b0;
		#100
		test_add;

		rst_n		= 1'b1;
		#500
		//forever #10 clk = ~clk; // generate a clock
		$finish;
	end


task test_add; 
		begin
				pc = 32'b0;
				encodeAddi(5'h0, 5'h3, 12'd5);
				encodeAddi(5'h0, 5'h4, 12'd2);
				encodeAdd(5'h3, 5'h4, 5'h5);
		end
 endtask

task encodeAddi;
		input [4:0] rs1;
		input [4:0] rd;
		input [11:0] immediate;
		begin
				instruction = {immediate, rs1, 3'b000, rd, `OPCODE_I_IMM};
				Core_inst.ProgMem_inst.progArray[pc] = instruction;
				$display("mem[%d] = %b", pc, Core_inst.ProgMem_inst.progArray[pc]);
				pc = pc + 32'd4;
	end
 endtask

	task encodeAdd;
	input [4:0] rs1;
	input [4:0] rs2;
	input [4:0] rd;
	begin
	 instruction = {7'b0, rs2, rs1, 3'b000, rd, `OPCODE_R_ALU};
	 Core_inst.ProgMem_inst.progArray[pc] = instruction;
	 $display("mem[%d] = %b", pc, Core_inst.ProgMem_inst.progArray[pc]);
	 pc = pc + 32'd4;
	end
 endtask

always @ (negedge clk) begin
		$display("reg5 = %d\npc = %d\ninst = %b", Core_inst.reg_file_inst.regFile[5], Core_inst.addr_progMem, Core_inst.instruction_progmem);
		$display("reg3 = %d", Core_inst.reg_file_inst.regFile[3]);
		$display("rs2_exec_unit_t = %d", Core_inst.rs2_exec_unit_t);
		$display("ALU_op_t = %d", Core_inst.ALU_op_t);
		$display("is_imm_t = %d", Core_inst.is_imm_t);
		$display("r_num_write_reg_file = %d", Core_inst.r_num_write_reg_file);

end

endmodule   