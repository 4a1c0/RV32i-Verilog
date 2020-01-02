// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

`include "../src/defines.vh"

`include"../src/top_pulp.v"

module tb();
	
		reg          clk            ;
		reg          rst_n          ;

		reg [31:0] instruction;
		reg [31:0] pc;
		reg [31:0] rd;
		reg [31:0] expectedResult;

	
	top top_inst(
		.clk				(clk),
		.rst_n				(rst_n)
	);

	always #50 clk = !clk;

    // Old way to test

	// initial begin 

	// 	$dumpfile("vcd/riscV.vcd");
	// 	$dumpvars(0, top_inst);
	// 	// Load memory
	// 	$readmemb("data/programMem_b.mem", top_inst.mem_prog_inst.progArray, 0, 3);
	// 	$readmemh("data/dataMem_h.mem", top_inst.mem_data_inst.dataArray, 0, 3);
		
	// 	pc = 32'b0;

	// 	// Initialize registers
	// 	clk = 1'b0;
	// 	rst_n = 1'b0;
	// 	#100
		
    //     $readmemh("data/dataMem_h.mem", top_inst.mem_data_inst.dataArray, 0, 3);
    //     //top_inst.mem_data_inst.dataArray[1] = 32'hff04a1c0;
	// 	//test_add;
	// 	//test_lui;
	// 	//test_auipc;
    //     //test_load;
    //     //test_store;
    //     test_jal;
    //     rst_n = 1'b0;
    //     #100
    //     test_beq;

	// 	$finish;
	// end


// ARITHMETICOLOGIC

task test_add; 
    begin
        $display ("ADD Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'd5);
        encodeAddi(5'h0, 5'h4, 12'd2);
        encodeAdd(5'h3, 5'h4, 5'h5);

        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 7) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be 7 but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
    end
endtask

task test_and;
    begin
        $display ("AND Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF);
        encodeAddi(5'h0, 5'h4, 12'hFF);
        encodeAnd(5'h3, 5'h4, 5'h5);
        //TEST
        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h000000FF) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h000000FF but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
    end
endtask


task test_andi;
    begin
        $display ("ANDI Test");
        pc = 32'b0;
        //encodeLW(5'h0, 5'h3, 12'h1);
        //encodeAndi(5'h3, 5'h4, 12'hFFF);
        encodeAddi(5'h0, 5'h3, 12'h444);
        encodeAndi(5'h3, 5'h5, 12'hF0F);

        rst_n		= 1'b1;
        #400; //300
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h0000404) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000404 but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end

    end
endtask
 
task test_slli;
    begin
        $display ("SLLI Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'd3);
        encodeSlli(5'h3, 5'h5, 5'h2);
        
        rst_n		= 1'b1;
        #400; //300
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h000000C) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h000000C but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
    end
endtask
 
task test_slti;
    begin
        $display ("SLTI Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFC); //-12
        encodeSlti(5'h3, 5'h5, 12'h8); //1
        encodeSlti(5'h3, 5'h6, 12'hFFF); //-1
        
        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h0000001) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000001 but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
        if (top_inst.core_inst.reg_file_inst.regFile[6] == 32'h0000001) $display ("    OK: reg6 is : %h", top_inst.core_inst.reg_file_inst.regFile[6]);
        else begin
            $display ("ERROR: reg6 has to be h0000001 but is: %h", top_inst.core_inst.reg_file_inst.regFile[6]);
            $fatal;
        end
    end
endtask
 
task test_sltiu;
    begin
    $display ("SLTIU Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFC); // 4092
        encodeSltiu(5'h3, 5'h5, 12'hFFF); // 4095
        encodeSltiu(5'h3, 5'h3, 12'h8);  // 8

        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h0000001) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h0000001 but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
        if (top_inst.core_inst.reg_file_inst.regFile[3] == 32'h0000000) $display ("    OK: reg3 is : %h", top_inst.core_inst.reg_file_inst.regFile[3]);
        else begin
            $display ("ERROR: reg3 has to be h0000001 but is: %h", top_inst.core_inst.reg_file_inst.regFile[3]);
            $fatal;
        end
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


// LOAD_STORE
task test_load;
    begin
        $display ("LOAD Test");
        pc = 32'b0;
        encodeLB(5'h0, 5'h3, 12'h4);
        encodeLH(5'h0, 5'h4, 12'h4);
        encodeLW(5'h0, 5'h5, 12'h4);
        encodeLHU(5'h0, 5'h6, 12'h4);
        encodeLBU(5'h0, 5'h7, 12'h4);
        //TEST
        rst_n		= 1'b1;
        #1600;  // 600
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'hf04a1c0f) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be hf04a1c0f but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end

    end
endtask

task test_store;
    begin
        pc = 32'b0;
        
        $display ("STORE Test");
        encodeLW(5'h0, 5'h1, 12'h0);
        encodeLW(5'h0, 5'h2, 12'h4);
        encodeLW(5'h0, 5'h3, 12'h8);
        encodeLW(5'h0, 5'h4, 12'hC);

        encodeSW(5'h0, 5'h1, 12'h10);
        encodeSH(5'h0, 5'h2, 12'h14);
        encodeSB(5'h0, 5'h3, 12'h18);
        encodeSW(5'h0, 5'h4, 12'h1C);

        encodeLW(5'h0, 5'h5, 12'h10);
        encodeLW(5'h0, 5'h6, 12'h14);
        encodeLW(5'h0, 5'h7, 12'h18);

        //TEST
        rst_n		= 1'b1;
        #2500; //1200
        if (top_inst.core_inst.reg_file_inst.regFile[5] == 32'h10101010) $display ("    OK: reg5 is : %h", top_inst.core_inst.reg_file_inst.regFile[5]);
        else begin
            $display ("ERROR: reg5 has to be h10101010 but is: %h", top_inst.core_inst.reg_file_inst.regFile[5]);
            $fatal;
        end
        if (top_inst.core_inst.reg_file_inst.regFile[6] == 32'h00001c0f) $display ("    OK: reg6 is : %h", top_inst.core_inst.reg_file_inst.regFile[6]);
        else begin
            $display ("ERROR: reg5 has to be h00001c0f but is: %h", top_inst.core_inst.reg_file_inst.regFile[6]);
            $fatal;
        end
        if (top_inst.core_inst.reg_file_inst.regFile[7] == 32'h00000011) $display ("    OK: reg7 is : %h", top_inst.core_inst.reg_file_inst.regFile[7]);
        else begin
            $display ("ERROR: reg5 has to be h00000011 but is: %h", top_inst.core_inst.reg_file_inst.regFile[7]);
            $fatal;
        end

    end
endtask

task test_jal;  // Not sure if the JAL works as intended
    begin
        $display ("JAL Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF); 
        encodeAddi(5'h0, 5'h4, 12'hFFF);
        encodeJal(5'h5, {21'h1FFFF4}); // -12
        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.program_counter_inst.addr == 0) $display ("  OK: PC is: %d", top_inst.core_inst.program_counter_inst.addr);
        else begin
            $display ("ERROR: PC has to be 0 but is: %d", top_inst.core_inst.program_counter_inst.addr);
            $fatal;
        end
    end
endtask


task test_beq;
    begin
        $display ("BEQ Test");
        pc = 32'b0;
        encodeAddi(5'h0, 5'h3, 12'hFFF);
        encodeAddi(5'h0, 5'h4, 12'hFFF);
        encodeBeq(5'h3, 5'h4, 13'hF0);
        
        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.program_counter_inst.addr == 252) $display ("    OK: PC is: %d", top_inst.core_inst.program_counter_inst.addr);
        else begin
            $display ("ERROR: PC has to be 252 but is: %d", top_inst.core_inst.program_counter_inst.addr);
            $fatal;
        end
    end
endtask


task test_csr;
    begin
        $display ("CSR Test");
        pc = 32'b0;
        encodeCsr(12'hC00, 5'h0, `FUNCT3_CSRRS, 5'h1);
        encodeCsr(12'hC01, 5'h0, `FUNCT3_CSRRS, 5'h2);
        encodeCsr(12'hC02, 5'h0, `FUNCT3_CSRRS, 5'h3);
        rst_n		= 1'b1;
        #500; //400
        if (top_inst.core_inst.reg_file_inst.regFile[3] == 32'h0000003) $display ("    OK: reg3 is : %h", top_inst.core_inst.reg_file_inst.regFile[3]);
        else begin
            $display ("ERROR: reg3 has to be h0000002 but is: %h", top_inst.core_inst.reg_file_inst.regFile[3]);
            $fatal;
        end
    end
endtask







task encodeAddi;
	input [4:0] rs1;
	input [4:0] rd;
	input [11:0] immediate;
	begin
		instruction = {immediate, rs1, 3'b000, rd, `OPCODE_I_IMM};
		top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
		pc = pc + 32'd4;
	end
endtask

task encodeAndi;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b111, rd, `OPCODE_I_IMM};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeSlti;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b010, rd, `OPCODE_I_IMM};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSltiu;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b011, rd, `OPCODE_I_IMM};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSlli;
    input [4:0] rs1;
    input [4:0] rd;
    input [4:0] immediate;
    begin
        instruction = {7'h0, immediate, rs1, `FUNCT3_SLLI, rd, `OPCODE_I_IMM}; // 3'b001
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeAdd;
	input [4:0] rs1;
	input [4:0] rs2;
	input [4:0] rd;
	begin
	 instruction = {7'b0, rs2, rs1, 3'b000, rd, `OPCODE_R_ALU};
	 top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
	 $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
	 pc = pc + 32'd4;
	end
endtask

task encodeAnd;
    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    begin
        instruction = {7'b0, rs2, rs1, 3'b111, rd, `OPCODE_R_ALU};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
	    $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSlt;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b010, rd, `OPCODE_R_ALU};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSltu;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, 3'b011, rd, `OPCODE_R_ALU};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSll;
    input [4:0] rs1;
    input [4:0] rd;
    input [4:0] immediate;
    begin
        instruction = {7'h0, immediate, rs1, 3'b001, rd, `OPCODE_R_ALU};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
		$display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeLui;
	input [4:0] rd;
	input [19:0] immediate;
	begin
	instruction = {immediate[19:0], rd, `OPCODE_U_LUI};
	top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
    $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
	pc = pc + 32'd4;
	end
endtask

task encodeAuipc;
    input [4:0] rd;
    input [19:0] immediate;
    begin
        instruction = {immediate[19:0], rd, `OPCODE_U_AUIPC};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeLB;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LB, rd, `OPCODE_I_LOAD};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeLH;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LH, rd, `OPCODE_I_LOAD};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeLW;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LW, rd, `OPCODE_I_LOAD};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeLBU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LBU, rd, `OPCODE_I_LOAD};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeLHU;
    input [4:0] rs1;
    input [4:0] rd;
    input [11:0] immediate;
    begin
        instruction = {immediate, rs1, `FUNCT3_LHU, rd, `OPCODE_I_LOAD};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeSB;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SB, offset[4:0], `OPCODE_S_STORE};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSH;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SH, offset[4:0], `OPCODE_S_STORE};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
 endtask

task encodeSW;
    input [4:0] rs1;
    input [4:0] rs2;
    input [11:0] offset;
    begin
        instruction = {offset[11:5], rs2, rs1, `FUNCT3_SW, offset[4:0], `OPCODE_S_STORE};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeJal;
    input [4:0] rd;
    input [20:0] immediate;
    begin
        instruction = {immediate[20], immediate[10:1], immediate[11], immediate[19:12], rd, `OPCODE_J_JAL};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask


task encodeBeq;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b0, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeBne;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b1, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBlt;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b100, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBge;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b101, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBltu;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b110, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask
 
task encodeBgeu;
    input [4:0] rs1;
    input [4:0] rs2;
    input [12:0] immediate;
    begin
        instruction = {immediate[12], immediate[10:5], rs2, rs1, 3'b11, immediate[4:1], immediate[11], `OPCODE_B_BRANCH};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask

task encodeCsr;
    input [11:0] addr;
    input [4:0] rs1;
    input [2:0] FUNCT3_OP;
    input [4:0] rd;
    
    begin
        instruction = {addr, rs1, FUNCT3_OP, rd, `OPCODE_I_SYSTEM};
        top_inst.mem_prog_inst.progArray[pc >> 2] = instruction;
        $display("mem[%d] = %b", pc, top_inst.mem_prog_inst.progArray[pc]);
        pc = pc + 32'd4;
    end
endtask



//always @ (negedge clk) begin
		// $display("reg5 = %d\npc = %d\ninst = %b", top_inst.reg_file_inst.regFile[5], top_inst.addr_progMem, top_inst.instruction_progmem);
		// $display("reg1 = %h", top_inst.core_inst.reg_file_inst.regFile[1]);
        // $display("reg2 = %h", top_inst.core_inst.reg_file_inst.regFile[2]);
        //$display("reg3 = %h", top_inst.core_inst.reg_file_inst.regFile[3]);
        // $display("reg4 = %h", top_inst.core_inst.reg_file_inst.regFile[4]);
        //$display("reg5 = %h", top_inst.core_inst.reg_file_inst.regFile[5]);
		// $display("rs2_exec_unit_t = %d", top_inst.rs2_exec_unit_t);
		// $display("ALU_op_t = %d", top_inst.ALU_op_t);
		//$display("is_imm_t = %d", top_inst.is_imm_t);
		// $display("r_num_write_reg_file = %d", top_inst.r_num_write_reg_file);
        //$display("pc = %d", top_inst.core_inst.program_counter_inst.addr);

//end

endmodule   