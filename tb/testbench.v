// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include "src/defines.vh"

`include"src/package.v"

module tb();
	
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
		
        $readmemh("data/dataMem_h.mem", package_inst.mem_data_inst.dataArray, 0, 3);
        //package_inst.mem_data_inst.dataArray[1] = 32'hff04a1c0;
		//test_add;
		//test_lui;
		//test_auipc;
        test_load;

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

task test_lui;
	begin
		encodeLui(5'h2, 20'hFFFFF);
		encodeLui(5'h3, 20'hAAAAA);
		encodeLui(5'h4, 20'h55555);
	end
endtask

task test_auipc;
  begin
  encodeAuipc(5'h2, 20'hFFFFF);
  encodeAuipc(5'h3, 20'hAAAAA);
  encodeAuipc(5'h4, 20'h55555);
  end
endtask

task test_load;
    begin
        pc = 32'b0;
        //encodeLoadW(5'h0, 5'h3, 12'h0);
        //encodeLoadH(5'h0, 5'h4, 12'h1);
        //encodeLoadHU(5'h0, 5'h5, 12'h1);
        encodeLoadB(5'h0, 5'h6, 12'h1);
        //encodeLoadBU(5'h0, 5'h7, 12'h1);
    end
 endtask

task encodeAddi;
	input [4:0] rs1;
	input [4:0] rd;
	input [11:0] immediate;
	begin
		instruction = {immediate, rs1, 3'b000, rd, `OPCODE_I_IMM};
		package_inst.mem_prog_inst.progArray[pc] = instruction;
		$display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
		pc = pc + 32'd4;
	end
endtask

task encodeAdd;
	input [4:0] rs1;
	input [4:0] rs2;
	input [4:0] rd;
	begin
	 instruction = {7'b0, rs2, rs1, 3'b000, rd, `OPCODE_R_ALU};
	 package_inst.mem_prog_inst.progArray[pc] = instruction;
	 $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
	 pc = pc + 32'd4;
	end
 endtask

task encodeLui;
	input [4:0] rd;
	input [19:0] immediate;
	begin
	instruction = {immediate[19:0], rd, `OPCODE_U_LUI};
	package_inst.mem_prog_inst.progArray[pc] = instruction;
    $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
	pc = pc + 32'd4;
	end
endtask

task encodeAuipc;
    input [4:0] rd;
    input [19:0] immediate;
    begin
        instruction = {immediate[19:0], rd, `OPCODE_U_AUIPC};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

 task encodeLoadB;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LB, rd, `OPCODE_I_LOAD};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask


always @ (negedge clk) begin
		// $display("reg5 = %d\npc = %d\ninst = %b", package_inst.reg_file_inst.regFile[5], package_inst.addr_progMem, package_inst.instruction_progmem);
		$display("reg6 = %d", package_inst.core_inst.reg_file_inst.regFile[6]);
		// $display("rs2_exec_unit_t = %d", package_inst.rs2_exec_unit_t);
		// $display("ALU_op_t = %d", package_inst.ALU_op_t);
		//$display("is_imm_t = %d", package_inst.is_imm_t);
		// $display("r_num_write_reg_file = %d", package_inst.r_num_write_reg_file);

end

endmodule   