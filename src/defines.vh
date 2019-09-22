
`ifndef _DEFINES_H_
`define _DEFINES_H_

// Parameters
`define REG_DATA_WIDTH 32   // Word Width
`define REG_ADDR_WIDTH 5   // Address With
`define REG_DEPTH 1 << `REG_ADDR_WIDTH  // Total number of positions (32)


`define MEM_DATA_WIDTH 32   // Word Width
`define MEM_ADDR_WIDTH 10   // Address With
`define MEM_DEPTH 1 << `MEM_ADDR_WIDTH  // Total number of positions (1024)




// Instrucitions types

// OPCODES
`define OPCODE_U_LUI		7'b0110111
`define OPCODE_U_AUIPC		7'b0010111
`define OPCODE_J_JAL		7'b1101111
`define OPCODE_I_JALR   	7'b1100111
`define OPCODE_B_BRANCH		7'b1100011
`define OPCODE_I_LOAD		7'b0000011  //
`define OPCODE_S_STORE		7'b0100011  //
`define OPCODE_I_IMM		7'b0010011
`define OPCODE_R_ALU		7'b0110011  // PROV NAME
`define OPCODE_I_FENCE		7'b0001111  //
`define OPCODE_I_SYSTEM		7'b1110011


// FUNCT3
//  I_JARL
`define FUNCT3_JARL			3'b000

//  B_BRANCH
`define FUNCT3_BEQ  		3'b000
`define FUNCT3_BNE  		3'b001
`define FUNCT3_BLT  		3'b100
`define FUNCT3_BGE  		3'b101
`define FUNCT3_BLTU 		3'b110
`define FUNCT3_BGEU 		3'b111

// I_LOAD
`define FUNCT3_LB  			3'b000
`define FUNCT3_LH  			3'b001
`define FUNCT3_LW	  		3'b010
`define FUNCT3_LBU  		3'b100
`define FUNCT3_LHU 			3'b101

//  S_STORES
`define FUNCT3_SB  			3'b000
`define FUNCT3_SH  			3'b001
`define FUNCT3_SW	  		3'b010

//  I_IMM
`define FUNCT3_ADDI			3'b000
`define FUNCT3_SLTI			3'b010
`define FUNCT3_SLTIU  		3'b011
`define FUNCT3_XORI  		3'b100
`define FUNCT3_ORI 			3'b110
`define FUNCT3_ANDI			3'b111
`define FUNCT3_SLLI			3'b001
`define FUNCT3_SRLI_SRAI	3'b101

//  R_ALU
`define FUNCT3_ADD_SUB		3'b000
`define FUNCT3_SLL     		3'b001
`define FUNCT3_SLT     		3'b010
`define FUNCT3_SLTU    		3'b011
`define FUNCT3_XOR     		3'b100
`define FUNCT3_SRL_SRA 		3'b101
`define FUNCT3_OR      		3'b110
`define FUNCT3_AND     		3'b111

//  I_FENCE
`define FUNCT3_FENCE 		3'b000
`define FUNCT3_FENCEI 		3'b001

//  I_SYSTEM
`define FUNCT3_ECALL_EBREAK	3'b000
`define FUNCT3_CSRRW		3'b001
`define FUNCT3_CSRRS  		3'b010
`define FUNCT3_CSRRC  		3'b011
`define FUNCT3_CSRRWI 		3'b101
`define FUNCT3_CSRRSI		3'b110
`define FUNCT3_CSRRCI		3'b111


// FUNCT7
//  I_IMM
`define FUNCT7_SRLI		7'b0000000
`define FUNCT7_SRAI		7'b0100000

//  R_ALU
`define FUNCT7_ADD		7'b0000000
`define FUNCT7_SUB		7'b0100000
`define FUNCT7_SRL		7'b0000000
`define FUNCT7_SRA		7'b0100000

// I_SYSTEM
`define IMM_ECALL		12'b000000000000
`define IMM_EBREAK		12'b000000000001

// ALU_OPERATIONS
`define ALU_OP_WIDTH		4

`define ALU_OP_ADD		0		
`define ALU_OP_SUB		1
`define ALU_OP_SLL		2
`define ALU_OP_SLT 		3
`define ALU_OP_SLTU		4
`define ALU_OP_XOR		5
`define ALU_OP_SRL		6
`define ALU_OP_SRA		7
`define ALU_OP_OR 		8
`define ALU_OP_AND		9

// LIS_OPERATIONS
`define LIS_OP_WIDTH		3

`define LIS_LB		0		
`define LIS_LH		1
`define LIS_LW		2
`define LIS_LBU 		3
`define LIS_LHU		4
`define LIS_SB		5
`define LIS_SH		6
`define LIS_SW		7


`endif