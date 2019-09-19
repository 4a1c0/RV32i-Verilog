`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module controlUnit (
    instruction,
    pc_i,
    ALU_op,
    is_imm_rs1_o,  //execution unit imm rs1
    imm_val_rs1_o,  //execution unit imm val rs1
    is_imm_rs2_o,  //execution unit imm rs2
    imm_val_rs2_o,  //execution unit imm val rs2
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
    input [`MEM_ADDR_WIDTH-1:0] pc_i;
    output [`ALU_OP_WIDTH-1:0] ALU_op;
    output is_imm_rs1_o;
    output is_imm_rs2_o;
    output [`MEM_DATA_WIDTH-1:0] imm_val_rs1_o;
    output [`MEM_DATA_WIDTH-1:0] imm_val_rs2_o;
    output is_load_store;
    output mem_w;
    output mem_r;
    output mem_to_reg;
    output reg_r;
    output [`REG_ADDR_WIDTH-1:0]r1_addr;
    output [`REG_ADDR_WIDTH-1:0]r2_addr;
    output [`REG_ADDR_WIDTH-1:0]reg_addr;


    reg is_imm_rs1_o;
    reg is_imm_rs2_o;

    reg reg_r;
    reg [`MEM_DATA_WIDTH-1:0] imm_val_rs1_o;
    reg [`MEM_DATA_WIDTH-1:0] imm_val_rs2_o;
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
        is_imm_rs1_o = 1'b0;
        is_imm_rs2_o = 1'b0;

    

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

        `OPCODE_U_LUI: begin  // Set and sign extend the 20-bit immediate (shited 12 bits left) and zero the bottom 12 bits into rd

            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = { imm20[19:0], {`MEM_DATA_WIDTH - 20 {1'b0}} };
            reg_r = 1'b1;
            reg_addr = rd;

            ALU_op = `ALU_OP_ADD;
            r1_addr = 5'd0;

        end

      

        `OPCODE_U_AUIPC: begin  // Place the PC plus the 20-bit signed immediate (shited 12 bits left) into rd (used before JALR)

            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = { imm20[19:0], {`MEM_DATA_WIDTH - 20 {1'b0}} };


            // Need to output 2 imm vals of the control unit to add the PC and a imm val

            is_imm_rs1_o = 1'b1;
            imm_val_rs1_o = pc_i;

            ALU_op = `ALU_OP_ADD;

            reg_r = 1'b1;
            reg_addr = rd;


        end

      

        `OPCODE_J_JAL: begin

          //pc <= {{11{imm20j[19]}}, imm20j, 1'b0};

        end

      

        `OPCODE_I_JALR: begin

      

        end

      

        `OPCODE_B_BRANCH: begin

      

         end

      

        `OPCODE_I_LOAD: begin  // Loads

      

        end

      

        `OPCODE_S_STORES: begin  // Stores

      

        end

      

        `OPCODE_I_IMM: begin
            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = { {`MEM_DATA_WIDTH - 12 {imm12[11]}}, imm12[11:0] };
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
`default_nettype wire