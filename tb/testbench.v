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
        //test_load;
        //test_store;
        test_jal;

		rst_n		= 1'b1;
		#1100
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
        encodeLB(5'h0, 5'h3, 12'h1);
        encodeLH(5'h0, 5'h4, 12'h1);
        encodeLW(5'h0, 5'h5, 12'h1);
        encodeLHU(5'h0, 5'h6, 12'h1);
        encodeLBU(5'h0, 5'h7, 12'h1);
    end
endtask

task test_store;
  begin
   pc = 32'b0;
   //Load data from memory to reg file
   encodeLW(5'h0, 5'h1, 12'h0);
   encodeLW(5'h0, 5'h2, 12'h1);
   encodeLW(5'h0, 5'h3, 12'h2);
   encodeLW(5'h0, 5'h4, 12'h3);

   encodeSH(5'h0, 5'h1, 12'd10);
   encodeSB(5'h0, 5'h2, 12'd11);
   encodeSB(5'h0, 5'h3, 12'd12);
   encodeSW(5'h0, 5'h4, 12'd13);

   encodeLW(5'h0, 5'h5, 12'd10);
  end
endtask

task test_jal;  // Not sure if the JAL works as intended
    begin
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF); 
        encodeAddi(5'h0, 5'h4, 12'hFFF);
        encodeJal(5'h5, {20'hFFFF9});
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

task encodeLB;
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

task encodeLH;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LH, rd, `OPCODE_I_LOAD};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

 task encodeLW;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LW, rd, `OPCODE_I_LOAD};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

 task encodeLBU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LBU, rd, `OPCODE_I_LOAD};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

  task encodeLHU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LHU, rd, `OPCODE_I_LOAD};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSB;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SB, offset[4:0], `OPCODE_S_STORE};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSH;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SH, offset[4:0], `OPCODE_S_STORE};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSW;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SW, offset[4:0], `OPCODE_S_STORE};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeJal;
    input [4:0] rd;
    input [20:0] immediate;
    begin
        instruction = {immediate[20], immediate[10:1], immediate[11], immediate[19:12], rd, `OPCODE_J_JAL};
        package_inst.mem_prog_inst.progArray[pc] = instruction;
        $display("mem[%d] = %b", pc, package_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask


always @ (negedge clk) begin
		// $display("reg5 = %d\npc = %d\ninst = %b", package_inst.reg_file_inst.regFile[5], package_inst.addr_progMem, package_inst.instruction_progmem);
		// $display("reg1 = %h", package_inst.core_inst.reg_file_inst.regFile[1]);
        // $display("reg2 = %h", package_inst.core_inst.reg_file_inst.regFile[2]);
         $display("reg3 = %h", package_inst.core_inst.reg_file_inst.regFile[3]);
        // $display("reg4 = %h", package_inst.core_inst.reg_file_inst.regFile[4]);
        $display("reg5 = %h", package_inst.core_inst.reg_file_inst.regFile[5]);
		// $display("rs2_exec_unit_t = %d", package_inst.rs2_exec_unit_t);
		// $display("ALU_op_t = %d", package_inst.ALU_op_t);
		//$display("is_imm_t = %d", package_inst.is_imm_t);
		// $display("r_num_write_reg_file = %d", package_inst.r_num_write_reg_file);
        $display("pc = %d", package_inst.core_inst.program_counter_inst.addr);

end

endmodule   