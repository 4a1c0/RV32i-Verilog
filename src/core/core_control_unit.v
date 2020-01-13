`default_nettype none
`timescale 1ns/1ps

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

// Module Declaration
module controlUnit 
    `ifdef CUSTOM_DEFINE
		#(parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH,
        parameter DATA_WIDTH = `REG_DATA_WIDTH,
        parameter TRANSFER_WIDTH = `MEM_TRANSFER_WIDTH,
        parameter CSR_OP_WIDTH = `CSR_OP_WIDTH,
        parameter CSR_ADDR_WIDTH = `CSR_ADDR_WIDTH,
        parameter ALU_OP_WIDTH = `ALU_OP_WIDTH,
        parameter LIS_OP_WIDTH = `LIS_OP_WIDTH,
        parameter BR_OP_WIDTH = `BR_OP_WIDTH,
        parameter DATA_ORIGIN_WIDTH = `DATA_ORIGIN_WIDTH,
        parameter REG_ADDR_WIDTH = `REG_ADDR_WIDTH,
        parameter CSRRW = `CSRRW,  // TODO: Separar en localparams
		parameter CSRRS = `CSRRS,
		parameter CSRRC = `CSRRC,
		parameter CSRRWI = `CSRRWI,
		parameter CSRRSI = `CSRRSI,
		parameter CSRRCI = `CSRRCI,
        parameter ALU_OP_ADD = `ALU_OP_ADD,
		parameter ALU_OP_SUB = `ALU_OP_SUB,
		parameter ALU_OP_SLL = `ALU_OP_SLL,
		parameter ALU_OP_SLT  = `ALU_OP_SLT,
		parameter ALU_OP_SLTU = `ALU_OP_SLTU,
		parameter ALU_OP_XOR = `ALU_OP_XOR,
		parameter ALU_OP_SRL = `ALU_OP_SRL,
		parameter ALU_OP_SRA = `ALU_OP_SRA,
		parameter ALU_OP_OR  = `ALU_OP_OR,
		parameter ALU_OP_AND = `ALU_OP_AND) 
	`else
		#(parameter MEM_ADDR_WIDTH = 10,
        parameter DATA_WIDTH = 32,
        parameter TRANSFER_WIDTH = 4,
        parameter CSR_OP_WIDTH = 3,  // 3
        parameter CSR_ADDR_WIDTH = 12,
        parameter ALU_OP_WIDTH = 4,
        parameter LIS_OP_WIDTH = 3,
        parameter BR_OP_WIDTH = 2,
        parameter DATA_ORIGIN_WIDTH = 2,
        parameter REG_ADDR_WIDTH = 5,
        parameter CSRRW = 1,  // TODO: Separar en localparams
		parameter CSRRS = 2,
		parameter CSRRC = 3,
		parameter CSRRWI = 4,
		parameter CSRRSI = 5,
		parameter CSRRCI = 6,
        parameter ALU_OP_ADD = 0,  // TODO: Separar en localparams
		parameter ALU_OP_SUB = 1,
		parameter ALU_OP_SLL = 2,
		parameter ALU_OP_SLT  = 3,
		parameter ALU_OP_SLTU = 4,
		parameter ALU_OP_XOR = 5,
		parameter ALU_OP_SRL = 6,
		parameter ALU_OP_SRA = 7,
		parameter ALU_OP_OR  = 8,
		parameter ALU_OP_AND = 9) 
	`endif
    (
        instruction,
        //pc_i,
        ALU_op,
        LIS_op,
        BR_op_o,
        csr_op_o,
        data_origin_o,
        data_target_o,
        is_branch_o,  // branch indicator
        //is_imm_rs1_o,  //execution unit imm rs1 // TODO Change the the way to indicate inmm or reg to a 2 bit bus
        
        //is_imm_rs2_o,  //execution unit imm rs2
        //imm_val_rs2_o,  //execution unit imm val rs2
        is_load_store,  // execution_unit 
        is_conditional_o,  // execution unit BR
        mem_w,  // mem_write
        reg_w,
        r1_addr,
        r2_addr,
        reg_addr,
        imm_val_o,  //execution unit imm val rs1
        write_transfer_o,
        csr_addr_o,
        csr_data_o

    //is_absolute_o,  // 
    );

    localparam OPCODE_U_LUI = 7'b0110111;
    localparam OPCODE_U_AUIPC = 7'b0010111;
    localparam OPCODE_J_JAL = 7'b1101111;
    localparam OPCODE_I_JALR = 7'b1100111;
    localparam OPCODE_B_BRANCH = 7'b1100011;
    localparam OPCODE_I_LOAD = 7'b0000011;  //
    localparam OPCODE_S_STORE = 7'b0100011;  //
    localparam OPCODE_I_IMM = 7'b0010011;
    localparam OPCODE_R_ALU = 7'b0110011;  // PROV NAME
    localparam OPCODE_I_FENCE = 7'b0001111;  //
    localparam OPCODE_I_SYSTEM = 7'b1110011;

    localparam REGS = 0;
    localparam RS2IMM_RS1 = 1;
    localparam RS2IMM_RS1PC = 2;

    // FUNCT3
    //  I_JARL
    localparam FUNCT3_JARL = 3'b000;

    //  B_BRANCH
    localparam FUNCT3_BEQ = 3'b000;
    localparam FUNCT3_BNE = 3'b001;
    localparam FUNCT3_BLT = 3'b100;
    localparam FUNCT3_BGE = 3'b101;
    localparam FUNCT3_BLTU = 'b110;
    localparam FUNCT3_BGEU = 'b111;

    // I_LOAD
    localparam FUNCT3_LB = 	3'b000;
    localparam FUNCT3_LH = 	3'b001;
    localparam FUNCT3_LW = 3'b010;
    localparam FUNCT3_LBU = 3'b100;
    localparam FUNCT3_LHU = 3'b101;

    //  S_STORES
    localparam FUNCT3_SB = 	3'b000;
    localparam FUNCT3_SH = 	3'b001;
    localparam FUNCT3_SW = 3'b010;

    //  I_IMM
    localparam FUNCT3_ADDI = 3'b000;
    localparam FUNCT3_SLTI = 3'b010;
    localparam FUNCT3_SLTIU = 3'b011;
    localparam FUNCT3_XORI = 3'b100;
    localparam FUNCT3_ORI = 3'b110;
    localparam FUNCT3_ANDI = 3'b111;
    localparam FUNCT3_SLLI = 3'b001;
    localparam FUNCT3_SRLI_SRAI	= 3'b101;

    //  R_ALU
    localparam FUNCT3_ADD_SUB = 3'b000;
    localparam FUNCT3_SLL= 3'b001;
    localparam FUNCT3_SLT= 3'b010;
    localparam FUNCT3_SLTU = 3'b011;
    localparam FUNCT3_XOR= 3'b100;
    localparam FUNCT3_SRL_SRA = 3'b101;
    localparam FUNCT3_OR = 3'b110;
    localparam FUNCT3_AND= 3'b111;

    //  I_SYSTEM
    localparam FUNCT3_ECALL_EBREAK = 3'b000;
    localparam FUNCT3_CSRRW = 3'b001;
    localparam FUNCT3_CSRRS = 3'b010;
    localparam FUNCT3_CSRRC = 3'b011;
    localparam FUNCT3_CSRRWI = 3'b101;
    localparam FUNCT3_CSRRSI = 3'b110;
    localparam FUNCT3_CSRRCI = 3'b111;

    // BR_OPERATIONS

    localparam BR_EQ = 0;	
    localparam BR_NE = 1;
    localparam BR_LT = 2;
    localparam BR_GE = 3;

    // LIS_OPERATIONS
    localparam LIS_LB = 0;
    localparam LIS_LH = 1;
    localparam LIS_LW = 2;
    localparam LIS_LBU = 3;
    localparam LIS_LHU = 4;
    localparam LIS_SB = 5;
    localparam LIS_SH = 6;
    localparam LIS_SW = 7;

    // DATA TARGET
	localparam DATA_TARGET_WIDTH = 2;
	localparam DATA_TARGET_ALU_O = 0; //{DATA_TARGET_WIDTH{1'b0}};
	localparam DATA_TARGET_MEM_WR = 1;
    localparam DATA_TARGET_PC_4 = 2;
	localparam DATA_TARGET_CSR = 3;
    

    input [DATA_WIDTH-1:0] instruction;
    //input [`MEM_ADDR_WIDTH-1:0] pc_i;
    output [ALU_OP_WIDTH-1:0] ALU_op;
    output [LIS_OP_WIDTH-1:0] LIS_op;
    output [BR_OP_WIDTH-1:0]  BR_op_o;
    output [DATA_ORIGIN_WIDTH-1:0] data_origin_o;  // To indicate what data to use by the execution unit 
    output [DATA_TARGET_WIDTH-1:0] data_target_o;
    //output is_imm_o;
    //output is_imm_rs2_o;
    output [DATA_WIDTH-1:0] imm_val_o;
    //output [`MEM_DATA_WIDTH-1:0] imm_val_rs2_o;
    output is_load_store;
    output mem_w;
    output reg_w;
    output [REG_ADDR_WIDTH-1:0]r1_addr;
    output [REG_ADDR_WIDTH-1:0]r2_addr;
    output [REG_ADDR_WIDTH-1:0]reg_addr;
    output is_branch_o;  // branch indicator
    //output is_absolute_o;
    output is_conditional_o;
    output [TRANSFER_WIDTH-1:0] write_transfer_o;

    output [CSR_OP_WIDTH-1 : 0] csr_op_o;
    output [CSR_ADDR_WIDTH-1 : 0] csr_addr_o;
    output [DATA_WIDTH-1 : 0] csr_data_o;

    //reg is_imm_rs1_o;
    //reg is_imm_rs2_o;

    reg mem_w;

    reg reg_w;
    reg [DATA_WIDTH-1:0] imm_val_o;
    //reg [`MEM_DATA_WIDTH-1:0] imm_val_rs2_o;
    reg [REG_ADDR_WIDTH-1:0]r1_addr;
    reg [REG_ADDR_WIDTH-1:0]r2_addr;
    reg [REG_ADDR_WIDTH-1:0]reg_addr;
  
    // Temp

    wire[DATA_WIDTH-1:0] instruction;

    

    reg[6:0]	opcode; 

    

    //  Type R

    reg[2:0]	funct3;

    reg[6:0]	funct7;

    

    //  Type U

    reg[19:0]	imm20;
    //reg is_absolute_o;

    

    // Type I

    reg[11:0] imm12;
    reg is_load_store;

    // Type S

    reg [11:0] imm12s;

    // Type B

    reg is_conditional_o;

    

    reg[11:0] imm12b;

    reg[19:0] imm20j;

    // Type J

    reg is_branch_o;

    // Decode

    reg[4:0]	rs1, rs2, rd;



    reg [ALU_OP_WIDTH-1:0] ALU_op;
    reg [LIS_OP_WIDTH-1:0] LIS_op;
    reg [BR_OP_WIDTH-1:0] BR_op_o;
    reg [DATA_ORIGIN_WIDTH-1:0] data_origin_o;
    reg [DATA_TARGET_WIDTH-1:0] data_target_o;


    reg [TRANSFER_WIDTH-1:0] write_transfer_o;
    reg [CSR_OP_WIDTH-1 : 0] csr_op_o;
    reg [CSR_ADDR_WIDTH-1 : 0] csr_addr_o;
    reg [DATA_WIDTH-1 : 0] csr_data_o;

    
    always@(*) begin

        mem_w = 1'b0;
        write_transfer_o = {TRANSFER_WIDTH{1'b0}};
        is_load_store = 1'b0;
        reg_w = 1'b0;
        is_branch_o = 1'b0;
        is_conditional_o = 1'b0;
        data_origin_o = 0;  //REGS;  // Dafault value 0
        data_target_o = {DATA_TARGET_WIDTH{1'b0}};  //DATA_TARGET_ALU_O;  // Dafault value 0
        ALU_op = 0;  //`ALU_OP_ADD;  // Dafault value 0
        BR_op_o = 0;  //`BR_EQ;  // Dafault value 0
        LIS_op = 0;  //`LIS_LB;  // Dafault value 0
        csr_op_o = {CSR_OP_WIDTH{1'b0}};  // Zero value to deactivate acces to CSR
        csr_addr_o = {CSR_ADDR_WIDTH{1'b0}};
        csr_data_o = {DATA_WIDTH{1'b0}};
        imm_val_o = {DATA_WIDTH{1'b0}};
        reg_addr = {REG_ADDR_WIDTH{1'b0}};
        r1_addr = {REG_ADDR_WIDTH{1'b0}};
        r2_addr = {REG_ADDR_WIDTH{1'b0}};
        

        

    

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
        
            default: begin
                $display("Ilegal OPCODE");  // TODO Throw interruption
            end

            OPCODE_U_LUI: begin  // Set and sign extend the 20-bit immediate (shited 12 bits left) and zero the bottom 12 bits into rd

                data_origin_o = RS2IMM_RS1;  // Send the immediate value and mantain RS1 the value, in dis case 0
                imm_val_o = { imm20[19:0], {DATA_WIDTH - 20 {1'b0}} };
                
                reg_w = 1'b1;  // Write the resut in RD
                reg_addr = rd;

                ALU_op = ALU_OP_ADD;  // Sum with 0
                r1_addr = {REG_ADDR_WIDTH{1'b0}};

                data_target_o = DATA_TARGET_ALU_O;  // Use the output from the ALU

            end


            OPCODE_U_AUIPC: begin  // Place the PC plus the 20-bit signed immediate (shited 12 bits left) into rd (used before JALR)

                data_origin_o = RS2IMM_RS1PC;  // Send the immediate value and PC at the execution unit
                imm_val_o = { imm20[19:0], {DATA_WIDTH - 20 {1'b0}} };

                reg_w = 1'b1;  // Write the resut in RD
                reg_addr = rd;


                // Need to output 2 imm vals of the control unit to add the PC and a imm val

                //is_imm_rs1_o = 1'b1;  // no PC in the control unit 
                //imm_val_rs1_o = pc_i;

                ALU_op = ALU_OP_ADD;  // Add the values

                data_target_o = DATA_TARGET_ALU_O;  // Use the output from the ALU


            end

        

            OPCODE_J_JAL: begin  // Jump to the PC plus 20-bit signed immediate while saving PC+4 into rd


                //is_imm_rs1_o = 1'b1;
                //imm_val_rs1_o = pc_i;

                is_branch_o = 1'b1;
                data_origin_o = RS2IMM_RS1PC;  // Send the immediate value and PC at the execution unit

                //r1_addr = `REG_ADDR_WIDTH'd0;

                imm_val_o = {{DATA_WIDTH - 21 {imm20j[19]}},  imm20j[19:0], 1'b0  }; // TODO last bit is used? or is always 0

                reg_w = 1'b1; // Write the resut in RD
                reg_addr = rd;

                ALU_op = ALU_OP_ADD;  // to add the immideate value to the PC

                data_target_o = DATA_TARGET_PC_4;  // Save PC+4 to rd

            end

        

            OPCODE_I_JALR: begin  // jalr       "Jump to rs1 plus the 12-bit signed immediate while saving PC+4 into rd"
                is_branch_o = 1'b1;
                data_origin_o = RS2IMM_RS1;  // Send the immediate value and mantain RS1 the value
                // Execution unit knows that also needs the PC

                r1_addr = rs1;

                ALU_op = ALU_OP_ADD;  

                imm_val_o = {{DATA_WIDTH - 12 {imm12[11]}},  imm12[11:0] }; // no ^2
                
                reg_w = 1'b1;  // Write the resut in RD
                reg_addr = rd;

                data_target_o = DATA_TARGET_PC_4;  // Save PC+4 to rd
        
            end

        

            OPCODE_B_BRANCH: begin
                is_branch_o = 1'b1;
                data_origin_o = REGS;  // Mantain RS2 value and RS1 value // DefaultValue
                is_conditional_o = 1'b1;
                // Execution unit knows that also needs immideate value
    
                imm_val_o = {{DATA_WIDTH - 13 {imm12b[11]}},  imm12b[11:0], 1'b0  }; // TODO last bit is used? or is always 0

                r1_addr = rs1;
                r2_addr = rs2;
                ALU_op = ALU_OP_SUB;

                case(funct3)
                    default: begin
                        $display("Ilegal BRANCH FUNCT3");  // TODO Throw interruption
                    end
                    FUNCT3_BEQ: BR_op_o = BR_EQ; // beq        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 == rs2"
                    FUNCT3_BNE: BR_op_o = BR_NE;  // bne        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 != rs2"
                    FUNCT3_BLT:begin  // blt        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (signed)"
                        ALU_op = ALU_OP_SLT;
                        BR_op_o = BR_LT;  
                    end
                    FUNCT3_BGE: begin  // bge        "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (signed)"
                        ALU_op = ALU_OP_SLT;
                        BR_op_o = BR_GE; 
                    end 
                    FUNCT3_BLTU: begin  // bltu       "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 < rs2 (unsigned)"
                        ALU_op = ALU_OP_SLTU;
                        BR_op_o = BR_LT;
                    end
                    FUNCT3_BGEU:begin  // bgeu       "Branch to PC relative 12-bit signed immediate (shifted 1 bit left) if rs1 >= rs2 (unsigned)"
                        ALU_op = ALU_OP_SLTU;
                        BR_op_o = BR_GE;
                    end            
                endcase
        

            end

        

            OPCODE_I_LOAD: begin  // Loads

                is_load_store = 1'b1;

                reg_w = 1'b1;
                r1_addr = rs1;
                reg_addr = rd;

                ALU_op = ALU_OP_ADD;  // to add the immideate value to the addr

                data_origin_o = RS2IMM_RS1;  // Send the immediate value and mantain RS1 the value
                imm_val_o = {{DATA_WIDTH - 12 {imm12[11]}},  imm12[11:0]  };

                case(funct3)
                    default: begin
                        $display("Ilegal LOAD FUNCT3");  // TODO Throw interruption
                    end
                    FUNCT3_LB: LIS_op = LIS_LB;  // lb         "Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                    FUNCT3_LH: LIS_op = LIS_LH;  // lh         "Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                    FUNCT3_LW: LIS_op = LIS_LW;  // lw         "Load 32-bit value from addr in rs1 plus the 12-bit signed immediate and place sign-extended result into rd"
                    FUNCT3_LBU: LIS_op = LIS_LBU;  // lbu        "Load 8-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd"
                    FUNCT3_LHU: LIS_op = LIS_LHU;  // lhu        "Load 16-bit value from addr in rs1 plus the 12-bit signed immediate and place zero-extended result into rd"
                                    
                endcase

                data_target_o = DATA_TARGET_MEM_WR;  // Load the value from memory to rd

            end

        

            OPCODE_S_STORE: begin  // Store

                is_load_store = 1'b1;


                r1_addr = rs1;
                r2_addr = rs2;


                ALU_op = ALU_OP_ADD;  // to add the immideate value to the addr

                data_origin_o = RS2IMM_RS1;  // Send the immediate value and mantain RS1 the value
                imm_val_o = {{DATA_WIDTH - 12 {imm12s[11]}},  imm12s[11:0]  };

                mem_w = 1'b1;  // Set the bit to write to memory

                case(funct3)
                    default: begin
                        $display("Ilegal STORE FUNCT3");  // TODO Throw interruption
                    end
                    FUNCT3_SB: begin  // sb         "Store 8-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
                        LIS_op = LIS_SB;
                        write_transfer_o = 4'b0001;
                    end
                    FUNCT3_SH: begin  // sh         "Store 16-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
                        LIS_op = LIS_SH;  
                        write_transfer_o = 4'b0011;
                    end 
                    FUNCT3_SW: begin // sw         "Store 32-bit value from the low bits of rs2 to addr in rs1 plus the 12-bit signed immediate"
                        LIS_op = LIS_SW;  
                        write_transfer_o = 4'b1111;
                    end 
                endcase


            end

        

            OPCODE_I_IMM: begin
                data_origin_o = RS2IMM_RS1;  // Send the immediate value and mantain RS1 the value
                imm_val_o = { {DATA_WIDTH - 12 {imm12[11]}}, imm12[11:0] };
                reg_w = 1'b1;
                r1_addr = rs1;
                reg_addr = rd;
                case(funct3)
                    FUNCT3_ADD_SUB: ALU_op = ALU_OP_ADD;// addi       "Add sign-extended 12-bit immediate to register rs1 and place the result in rd"
                    FUNCT3_SLL:     ALU_op = ALU_OP_SLL;  // slli       "Shift rs1 left by the 5 or 6 (RV32/64) bit (RV64) immediate and place the result into rd"
                    FUNCT3_SLT:     ALU_op = ALU_OP_SLT;  // slti       "Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (signed)"
                    FUNCT3_SLTU:    ALU_op = ALU_OP_SLTU;  // sltiu      "Set rd to 1 if rs1 is less than the sign-extended 12-bit immediate, otherwise set rd to 0 (unsigned)"
                    FUNCT3_XOR:     ALU_op = ALU_OP_XOR;  // xori       "Set rd to the bitwise xor of rs1 with the sign-extended 12-bit immediate"
                    FUNCT3_SRL_SRA: ALU_op = funct7[5] == 1'b1 ? ALU_OP_SRA : ALU_OP_SRL; // srli       "Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd" 
                                                                                            // srai       "Shift rs1 right by the 5 or 6 (RV32/64) bit immediate and place the result into rd while retaining the sign"
                    FUNCT3_OR:      ALU_op = ALU_OP_OR;  // ori        "Set rd to the bitwise or of rs1 with the sign-extended 12-bit immediate"
                    FUNCT3_AND:     ALU_op = ALU_OP_AND;  // andi       "Set rd to the bitwise and of rs1 with the sign-extended 12-bit immediate"
                endcase

                data_target_o = DATA_TARGET_ALU_O;  // Use the output from the ALU

            end

        

            OPCODE_R_ALU: begin
                reg_w = 1'b1;
                r1_addr = rs1;
                r2_addr = rs2;
                reg_addr = rd;
                case(funct3)
                    FUNCT3_ADD_SUB: ALU_op = funct7[5] == 1'b1 ? ALU_OP_SUB : ALU_OP_ADD;
                    FUNCT3_SLL:     ALU_op = ALU_OP_SLL;
                    FUNCT3_SLT:     ALU_op = ALU_OP_SLT;
                    FUNCT3_SLTU:    ALU_op = ALU_OP_SLTU;
                    FUNCT3_XOR:     ALU_op = ALU_OP_XOR;
                    FUNCT3_SRL_SRA: ALU_op = funct7[5] == 1'b1 ? ALU_OP_SRA : ALU_OP_SRL;
                    FUNCT3_OR:      ALU_op = ALU_OP_OR;
                    FUNCT3_AND:     ALU_op = ALU_OP_AND;
                endcase

                data_target_o = DATA_TARGET_ALU_O;  // Use the output from the ALU

            end

        

            OPCODE_I_FENCE: begin
            // fence      "Order device I/O and memory accesses viewed by other threads and devices"
            // fence.i    "Synchronize the instruction and data streams
            end

        

            OPCODE_I_SYSTEM: begin  // SYSTEM + CSR  // TODO Add control signals to enable CSR unit
                reg_w = 1'b1;
                reg_addr = rd;
                csr_addr_o = imm12;
                
                
                case(funct3)
                    default: begin
                        $display("Ilegal SYSTEM FUNCT3");  // TODO Throw interruption
                    end
                    FUNCT3_ECALL_EBREAK: ;  // NOP
                    FUNCT3_CSRRW:begin  // CSRRW – for CSR reading and writing (CSR content is read to a destination register and source-register content is then copied to the CSR);
                        csr_op_o = CSRRW;
                        csr_data_o = rs1;
                    end
                    FUNCT3_CSRRS:begin  // CSRRS – for CSR reading and setting (CSR content is read to the destination register and then its content is set according to the source register bit-mask);
                        csr_op_o = CSRRS;
                        csr_data_o = rs1;
                    end
                    FUNCT3_CSRRC:begin  // CSRRC – for CSR reading and clearing (CSR content is read to the destination register and then its content is cleared according to the source register bit-mask);
                        csr_op_o = CSRRC;
                        csr_data_o = rs1;
                    end
                    FUNCT3_CSRRWI:begin  // CSRRWI – the CSR content is read to the destination register and then the immediate constant is written into the CSR;
                        csr_op_o = CSRRWI;
                        csr_data_o = rs1;
                    end
                    FUNCT3_CSRRSI:begin  // CSRRSI – the CSR content is read to the destination register and then set according to the immediate constant;
                        csr_op_o = CSRRSI;
                        csr_data_o = rs1;
                    end
                    FUNCT3_CSRRCI:begin  // CSRRCI – the CSR content is read to the destination register and then cleared according to the immediate constant;
                        csr_op_o = CSRRCI;
                        csr_data_o = rs1;
                    end
                endcase

                data_target_o = DATA_TARGET_CSR;  // Use the output from the ALU

            end
        endcase

    end
endmodule

`default_nettype wire