`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module controlUnit (
    instruction,
    ALU_op,
    is_imm,  //execution unit imm
    imm_val,  //execution unit imm val
    is_load_store,  // execution_unit 
    mem_w,
    mem_r,
    mem_to_reg,
    reg_r,
    r1_addr,
    r2_addr,
    reg_addr
    );

    input [`MEM_DATA_WIDTH-1:0] instruction;
    output [`ALU_OP_WIDTH-1:0] ALU_op;
    output is_imm;
    output [`MEM_DATA_WIDTH-1:0] imm_val;
    output is_load_store;
    output mem_w;
    output mem_r;
    output mem_to_reg;
    output reg_r;
    output [`REG_ADDR_WIDTH-1:0]r1_addr;
    output [`REG_ADDR_WIDTH-1:0]r2_addr;
    output [`REG_ADDR_WIDTH-1:0]reg_addr;


    reg is_imm;

    reg reg_r;
    reg [`MEM_DATA_WIDTH-1:0] imm_val;
    reg [`REG_ADDR_WIDTH-1:0]r1_addr;
    reg [`REG_ADDR_WIDTH-1:0]r2_addr;
    reg [`REG_ADDR_WIDTH-1:0]reg_addr;
  
 // Temp

    wire[`MEM_DATA_WIDTH-1:0] instruction;

  

  reg[6:0]	opcode; 

  

  //  Type R

  reg[2:0]	funct3;

  reg[6:0]	funct7;

  

  //  Type U

  reg[19:0]	imm20;

  

  // Type I

  reg[11:0] imm12;

  

  // Type B

  

  reg[11:0] imm12b;

  reg[19:0] imm20j;



  // Decode

  reg[4:0]	rs1, rs2, rd;

  reg		s1_imm, s2_imm;  

  reg		jump;

  reg[`ALU_OP_WIDTH-1:0] ALU_op;

  
    always@(*) begin
        is_imm = 1'b0;

    

    // Decode

        opcode 	= instruction[6:0]; 

        funct7 	= instruction[31:25];  

        funct3 	= instruction[14:12]; 

        imm20 	= instruction[31:12];

        imm12 = instruction[31:20];

        rd 	= instruction[11:7];

        imm20j 	= {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};

        imm12b 	= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};

        rs1 = instruction[19:15];

        rs2 = instruction[24:20];

        rd = instruction[11:7];

  
    case(opcode)

        `OPCODE_U_LUI: begin

              //s2 <= {imm20, 12'd0};

          //s2_imm <= 1'b1;

          //s1_imm <= 1'b1;

      end

      

      `OPCODE_U_AUIPC: begin

          //s1 <= {imm20, 12'd0};

          //s2 <= pc;

      end

      

      `OPCODE_J_JAL: begin

          //pc <= {{11{imm20j[19]}}, imm20j, 1'b0};

      end

      

      `OPCODE_I_JALR: begin

      

      end

      

      `OPCODE_B_BRANCH: begin

      

      end

      

      `OPCODE_I_LOAD: begin

      

      end

      

      `OPCODE_S_STORES: begin

      

      end

      

      `OPCODE_I_IMM: begin
            is_imm = 1'b1;
            imm_val = imm12;
            reg_r = 1'b1;
            r1_addr = rs1;
            reg_addr = rd;
            case(funct3)
                `FUNCT3_ADD_SUB: ALU_op = funct7[5] ? `ALU_OP_SUB : `ALU_OP_ADD;
                `FUNCT3_SLL:     ALU_op = `ALU_OP_SLL;
                `FUNCT3_SLT:     ALU_op = `ALU_OP_SLT;
                `FUNCT3_SLTU:    ALU_op = `ALU_OP_SLTU;
                `FUNCT3_XOR:     ALU_op = `ALU_OP_XOR;
                `FUNCT3_SRL_SRA: ALU_op = funct7[5] ? `ALU_OP_SRA : `ALU_OP_SRL;
                `FUNCT3_OR:      ALU_op = `ALU_OP_OR;
                `FUNCT3_AND:     ALU_op = `ALU_OP_AND;
            endcase

      

      end

      

      `OPCODE_R_ALU: begin
            reg_r = 1'b1;
            r1_addr = rs1;
            r2_addr = rs2;
            reg_addr = rd;
            case(funct3)
                `FUNCT3_ADD_SUB: ALU_op = funct7[5] ? `ALU_OP_SUB : `ALU_OP_ADD;
                `FUNCT3_SLL:     ALU_op = `ALU_OP_SLL;
                `FUNCT3_SLT:     ALU_op = `ALU_OP_SLT;
                `FUNCT3_SLTU:    ALU_op = `ALU_OP_SLTU;
                `FUNCT3_XOR:     ALU_op = `ALU_OP_XOR;
                `FUNCT3_SRL_SRA: ALU_op = funct7[5] ? `ALU_OP_SRA : `ALU_OP_SRL;
                `FUNCT3_OR:      ALU_op = `ALU_OP_OR;
                `FUNCT3_AND:     ALU_op = `ALU_OP_AND;
            endcase

      

      end

      

      `OPCODE_I_FENCE: begin

      

      end

      

      `OPCODE_I_SYSTEM: begin

      

      

      end

      

     endcase

    end

 
endmodule
