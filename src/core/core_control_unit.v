`default_nettype none
`timescale 1ns/1ps

`include "src/defines.vh"

// Module Declaration
module controlUnit (
    instruction,
    pc_i,
    ALU_op,
    LIS_op,
    is_imm_rs1_o,  //execution unit imm rs1
    imm_val_rs1_o,  //execution unit imm val rs1
    is_imm_rs2_o,  //execution unit imm rs2
    imm_val_rs2_o,  //execution unit imm val rs2
    is_load_store,  // execution_unit 
    mem_w,  // mem_write
    mem_to_reg,
    reg_r,
    r1_addr,
    r2_addr,
    reg_addr,
    is_branch_o  // branch indicator
    );

    input [`MEM_DATA_WIDTH-1:0] instruction;
    input [`MEM_ADDR_WIDTH-1:0] pc_i;
    output [`ALU_OP_WIDTH-1:0] ALU_op;
    output [`LIS_OP_WIDTH-1:0] LIS_op;
    output is_imm_rs1_o;
    output is_imm_rs2_o;
    output [`MEM_DATA_WIDTH-1:0] imm_val_rs1_o;
    output [`MEM_DATA_WIDTH-1:0] imm_val_rs2_o;
    output is_load_store;
    output mem_w;
    output mem_to_reg;
    output reg_r;
    output [`REG_ADDR_WIDTH-1:0]r1_addr;
    output [`REG_ADDR_WIDTH-1:0]r2_addr;
    output [`REG_ADDR_WIDTH-1:0]reg_addr;
    output is_branch_o;  // branch indicator


    reg is_imm_rs1_o;
    reg is_imm_rs2_o;

    reg mem_w;
    reg mem_to_reg;

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
    reg is_load_store;

    // Type S

    reg [11:0] imm12s;

    // Type B

    

    reg[11:0] imm12b;

    reg[19:0] imm20j;

    // Type J

    reg is_branch_o;

    // Decode

    reg[4:0]	rs1, rs2, rd;



    reg[`ALU_OP_WIDTH-1:0] ALU_op;
    reg[`LIS_OP_WIDTH-1:0] LIS_op;

    
    always@(*) begin
        is_imm_rs1_o = 1'b0;
        is_imm_rs2_o = 1'b0;
        mem_w = 1'b0;
        mem_to_reg = 1'b0;
        is_load_store = 1'b0;
        reg_r = 1'b0;
        is_branch_o = 1'b0;
        

    

    // Decode

        opcode 	= instruction[6:0]; 

        funct7 	= instruction[31:25];  

        funct3 	= instruction[14:12]; 

        imm20 	= instruction[31:12];

        imm12 = instruction[31:20];

        rd 	= instruction[11:7];

        imm20j 	= {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};

        imm12b 	= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};

        imm12s = {instruction[31:25], instruction[11:7]};

        rs1 = instruction[19:15];

        rs2 = instruction[24:20];

        rd = instruction[11:7];

  
    case(opcode)


// jal        "Jump to the PC plus 20-bit signed immediate while saving PC+4 into rd"
// jalr       "Jump to rs1 plus the 12-bit signed immediate while saving PC+4 into rd"
// beq        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 == rs2"
// bne        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 != rs2"
// blt        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (signed)"
// bge        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (signed)"
// bltu       "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (unsigned)"
// bgeu       "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (unsigned)"


// fence      "Order device I/O and memory accesses viewed by other threads and devices"
// fence.i    "Synchronize the instruction and data streams

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

      

        `OPCODE_J_JAL: begin  // Jump to the PC plus 20-bit signed immediate while saving PC+4 into rd

          //pc <= {{11{imm20j[19]}}, imm20j, 1'b0};
            is_imm_rs1_o = 1'b1;
            imm_val_rs1_o = pc_i;

            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = {{`MEM_DATA_WIDTH - 21 {imm20j[19]}},  imm20j[19:0], 1'b0  }; // TODO last bit is used? or is always 0

            reg_r = 1'b1;
            reg_addr = rd;

            ALU_op = `ALU_OP_ADD;  // to add the immideate value to the PC


            is_branch_o = 1'b1;

                

        end

      

        `OPCODE_I_JALR: begin

      

        end

      

        `OPCODE_B_BRANCH: begin

      

         end

      

        `OPCODE_I_LOAD: begin  // Loads

            is_load_store = 1'b1;
            mem_to_reg = 1'b1;  // not in use

            reg_r = 1'b1;
            r1_addr = rs1;
            reg_addr = rd;

            ALU_op = `ALU_OP_ADD;  // to add the immideate value to the addr

            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = {{`MEM_DATA_WIDTH - 12 {imm12[11]}},  imm12[11:0]  };

            case(funct3)
                `FUNCT3_LB: LIS_op = `LIS_LB;  // lb         "Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                `FUNCT3_LH: LIS_op = `LIS_LH;  // lh         "Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                `FUNCT3_LW: LIS_op = `LIS_LW;  // lw         "Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                `FUNCT3_LBU: LIS_op = `LIS_LBU;  // lbu        "Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd"
                `FUNCT3_LHU: LIS_op = `LIS_LHU;  // lhu        "Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd"
                                
            endcase

      

        end

      

        `OPCODE_S_STORE: begin  // Store

            is_load_store = 1'b1;


            r1_addr = rs1;
            r2_addr = rs2;


            ALU_op = `ALU_OP_ADD;  // to add the immideate value to the addr

            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = {{`MEM_DATA_WIDTH - 12 {imm12s[11]}},  imm12s[11:0]  };

            mem_w = 1'b1;  // Set the bit to write to memory

            case(funct3)
                `FUNCT3_SB: LIS_op = `LIS_SB;  // sb         "Store 8-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
                `FUNCT3_SH: LIS_op = `LIS_SH;  // sh         "Store 16-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
                `FUNCT3_SW: LIS_op = `LIS_SW;  // sw         "Store 32-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
            endcase

      

        end

      

        `OPCODE_I_IMM: begin
            is_imm_rs2_o = 1'b1;
            imm_val_rs2_o = { {`MEM_DATA_WIDTH - 12 {imm12[11]}}, imm12[11:0] };
            reg_r = 1'b1;
            r1_addr = rs1;
            reg_addr = rd;
            case(funct3)
                `FUNCT3_ADD_SUB: ALU_op = `ALU_OP_ADD;// addi       "Add sign-extended 12-bit immediate to register rs1 and place the result in rd"
                `FUNCT3_SLL:     ALU_op = `ALU_OP_SLL;  // slli       "Shift rs1 left by the 5 or 6 (RV32/64) bit (RV64) immediate and place the result into rd"
                `FUNCT3_SLT:     ALU_op = `ALU_OP_SLT;  // slti       "Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (signed)"
                `FUNCT3_SLTU:    ALU_op = `ALU_OP_SLTU;  // sltiu      "Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (unsigned)"
                `FUNCT3_XOR:     ALU_op = `ALU_OP_XOR;  // xori       "Set rd to the bitwise xor of rs1 with the sign-extended 12-bit immediate"
                `FUNCT3_SRL_SRA: ALU_op = funct7[5] == 1'b1 ? `ALU_OP_SRA : `ALU_OP_SRL; // srli       "Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd" 
                                                                                         // srai       "Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd while retaining the sign"
                `FUNCT3_OR:      ALU_op = `ALU_OP_OR;  // ori        "Set rd to the bitwise or of rs1 with the sign-extended 12-bit immediate"
                `FUNCT3_AND:     ALU_op = `ALU_OP_AND;  // andi       "Set rd to the bitwise and of rs1 with the sign-extended 12-bit immediate"
            endcase

      

        end

      

        `OPCODE_R_ALU: begin
            reg_r = 1'b1;
            r1_addr = rs1;
            r2_addr = rs2;
            reg_addr = rd;
            case(funct3)
                `FUNCT3_ADD_SUB: ALU_op = funct7[5] == 1'b1 ? `ALU_OP_SUB : `ALU_OP_ADD;
                `FUNCT3_SLL:     ALU_op = `ALU_OP_SLL;
                `FUNCT3_SLT:     ALU_op = `ALU_OP_SLT;
                `FUNCT3_SLTU:    ALU_op = `ALU_OP_SLTU;
                `FUNCT3_XOR:     ALU_op = `ALU_OP_XOR;
                `FUNCT3_SRL_SRA: ALU_op = funct7[5] == 1'b1 ? `ALU_OP_SRA : `ALU_OP_SRL;
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