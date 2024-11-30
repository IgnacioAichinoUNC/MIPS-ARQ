`timescale 1ns / 1ps

//LW:   100011   base         RT     OFFSET
//LWU:  100111   base         RT     OFFSET
//LB:   100000   base         RT     OFFSET
//LBU:  100100   base         RT     OFFSET
//LH:   100001   base         RT     OFFSET
//LHU:  100101   base         RT     OFFSET
//LUI:  001111   00000        RT     IMMEDIATE
//SW:   101011    base        RT     OFFSET
//SB:   101000    base        RT     OFFSET
//SH:   101001    base        RT     OFFSET
//ADD:  000000     RS         RT     RD     00000      100000
//SUB:  000000     RS         RT     RD     00000      100010
//SUBU: 000000     RS         RT     RD     00000      100011
//AND:  000000     RS         RT     RD     00000      100100
//ANDI: 001100     RS         RT     IMMEDIATE
//OR:   000000     RS         RT     RD     00000      100101
//ORI:  001101     RS        RT     IMMEDIATE
//NOR:  000000     RS         RT     RD     00000      100111
//XOR:  000000     RS         RT     RD     00000      100110
//XORI: 001110     RS         RT     IMMEDIATE
//SLT:  000000     RS         RT     RD     00000      101010
//SLTI: 001010     RS         RT     IMMEDIATE
//BEQ:  000100     RS         RT     OFFSET
//BNE:  000101     RS         RT     OFFSET
//J:    000010     INSTR_INDEX
//ADDI: 001000     RS         RT     IMMEDIATE
//SLL:  000000     000000     RT     RD     sa         000000
//SRL:  000000     000000     RT     RD     sa         000010


module UnitControl
    #(
        parameter   BITS_SIZE =   6
    )
    (
        input   wire    [BITS_SIZE-1:0] i_ctl_instruction_op,
        input   wire    [BITS_SIZE-1:0] i_ctl_instr_funct,
        output  wire                    o_register_rd,
        output  wire                    o_jump,
        output  wire                    o_jal,
        output  wire                    o_branch,
        output  wire                    o_neq_branch,
        output  wire                    o_mem_to_reg,
        output  wire    [1:0]           o_unit_alu_op,
        output  wire                    o_mem_write,
        output  wire                    o_alu_src,
        output  wire                    o_register_write,
        output  wire    [1:0]           o_extension_mode,
        output  wire                    o_mem_read,
        output  wire    [1:0]           o_datamem_size,
        output  wire    [1:0]           o_size_filterL,
        output  wire                    o_zero_extend,
        output  wire                    o_lui,
        output  wire                    o_jalR,
        output  wire                    o_halt
    );


 // OP local param   
localparam LW     = 6'b100011;
localparam LWU    = 6'b100111;
localparam LB     = 6'b100000;
localparam LBU    = 6'b100100;
localparam LH     = 6'b100001;
localparam LHU    = 6'b100101;
localparam LUI    = 6'b001111;
localparam SW     = 6'b101011;
localparam SB     = 6'b101000;
localparam SH     = 6'b101001;
localparam BEQ    = 6'b000100;
localparam BNE    = 6'b000101;
localparam J      = 6'b000010;
localparam JAL    = 6'b000011;
localparam BAS    = 6'b000000;
localparam ADDI   = 6'b001000;
localparam ANDI   = 6'b001100;
localparam SLTI   = 6'b001010;
localparam ORI    = 6'b001101;
localparam XORI   = 6'b001110;
localparam JALR   = 6'b001001;
localparam JR     = 6'b001000;
localparam HALT   = 6'b111111;

    reg         reg_rd;             // 1 en JALR y todas las de tipo R menos JR
    reg         reg_jump;           // 1 en Jump (J) o JAL
    reg         reg_jal;            // 1 en JALR o JAL
    reg         reg_branch;         // 1 en (BEQ)
    reg         reg_neq_branch;     // 1 en (BNE)
    reg         reg_mem_read;       // 1 en LW (Load Word), LWU (Load Word Unsigned), LB (Load Byte), LBU (Load Byte Unsigned), LH (Load Halfword), LHU (Load Halfword Unsigned), LUI (Load Upper Inmediate)
    reg         reg_mem_to_reg;     // 1 en LW (Load Word), LWU (Load Word Unsigned), LB (Load Byte), LBU (Load Byte Unsigned), LH (Load Halfword), LHU (Load Halfword Unsigned), LUI (Load Upper Inmediate)
   
    reg [1:0]   reg_unit_alu_op;    //00 -> suma, 01 -> resta, 10 -> depende del funct de la instrucción, 11 -> depende del op de la instrucción
                                        //00 -> JALR, JR, ADDI, LW, LWU, LB, LBU, LH, LHU, LUI, SW, SB, SH, J, JAL, HALT
                                        //01 -> BEQ, BNE
                                        //10 -> tipo R (que no sean JALR ni JR)
                                        //11 -> ANDI, ORI, SLTI, XORI, caso default
   
    reg         reg_mem_write;      // 1 en SW (Store Word), SB (Store Byte), SH (Store Halfword)
    reg         reg_alu_src;        // 1 en ADDI, ANDI, ORI, SLTI, XORI, LW, LWU, LB, LBU, LH, LHU, SW, SB, SH
    reg         reg_register_write;  //1 en JALR, tipo R (menos JR), ADDI, ANDI, ORI, SLTI, XORI, LW, LWU, LB, LBU, LH, LHU, LUI, JAL
    
    reg [1:0]   reg_extend_mode;    //00 -> coloca los 16 bits inmediatos en la parte baja y la parte alta la completa repitiendo el bit más significativo del inmediato
                                        //   -> JALR, JR, todas las demás de tipo R, ADDI, SLTI, LW, LWU, LB, LBU, LH, LHU, SW, SB, SH, BEQ, BNE, J, JAL, HALT, default
                                    //01 -> coloca los 16 bits inmediatos en la parte baja y la parte alta la completa con 0
                                        //   -> ANDI, ORI, XORI
                                    //10 -> coloca 0 en la parte baja  y en la parte alta coloca los 16 bits inmediatos
                                        //   -> LUI

    reg [1:0]   reg_datamem_size;   //DATO STORE
                                        //00 -> JALR, JR, todas las demás de tipo R, ADDI, ANDI, ORI, SLTI, XORI, LW, LWU, LB, LBU, LH, LHU, LUI, SW, BEQ, BNE, J, JAL, HALT, default
                                        //01 -> SB
                                        //10 -> SH
    reg [1:0]   reg_size_filter_L;   //DATO WB PARA EL LOAD
                                        //00 -> JALR, JR, todas las demás de tipo R, ADDI, ANDI, ORI, SLTI, XORI, LW, LWU, LUI, SW, SB, SH, BEQ, BNE, J, JAL, HALT, default
                                        //01 -> LB, LBU
                                        //10 -> LH, LHU
    reg         reg_zero_extend;    // 1 en LBU, LHU
    reg         reg_lui;            // 1 en LUI
    reg         reg_jalR;           // 1 en JALR o JR
    reg         reg_halt;           // 1 en HALT

    always @(*)
    begin : Decoder
        case(i_ctl_instruction_op) 
            BAS:
            if(i_ctl_instr_funct == JALR) // los bits [5:0] de la instrucción
            begin
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_rd              <=  1'b1;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b1;
                reg_branch          <=  1'b0;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b1;
                reg_halt            <=  1'b0;
            end
            else if (i_ctl_instr_funct == JR)
            begin
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b1;
                reg_halt            <=  1'b0;
            end
            else
            begin
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b10;
                reg_rd              <=  1'b1;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            ADDI:
            begin
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            ANDI:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b11;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b01;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            ORI:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b11;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b01;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            SLTI:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b11;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            XORI:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b11;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b01;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LW:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LWU:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LB:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b01;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LBU:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b01;
                reg_zero_extend     <=  1'b1;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LH:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b10;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LHU:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b10;
                reg_zero_extend     <=  1'b1;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            LUI:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b1;
                reg_mem_to_reg      <=  1'b1;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b10;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b1;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end


            SW:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b1;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;

            end

            SB:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b1;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b01;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;

            end
            SH:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b1;
                reg_alu_src         <=  1'b1;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b10;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            BEQ:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b1;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b01;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            BNE:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b1;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b01;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            J:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b1;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

           JAL:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b1;
                reg_jal             <=  1'b1;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b1;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end

            HALT:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b00;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b1;
            end

            default:
            begin
                reg_rd              <=  1'b0;
                reg_jump            <=  1'b0;
                reg_jal             <=  1'b0;
                reg_branch          <=  1'b0;
                reg_neq_branch      <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_mem_to_reg      <=  1'b0;
                reg_unit_alu_op     <=  2'b11;
                reg_mem_write       <=  1'b0;
                reg_alu_src         <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_extend_mode     <=  2'b00;
                reg_datamem_size    <=  2'b00;
                reg_size_filter_L   <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_jalR            <=  1'b0;
                reg_halt            <=  1'b0;
            end
        endcase
    end

    assign  o_register_rd       =   reg_rd;
    assign  o_jump              =   reg_jump;
    assign  o_jal               =   reg_jal;
    assign  o_branch            =   reg_branch;
    assign  o_neq_branch        =   reg_neq_branch;
    assign  o_mem_read          =   reg_mem_read;
    assign  o_mem_to_reg        =   reg_mem_to_reg;
    assign  o_unit_alu_op       =   reg_unit_alu_op;
    assign  o_mem_write         =   reg_mem_write;
    assign  o_alu_src           =   reg_alu_src;
    assign  o_register_write    =   reg_register_write;
    assign  o_extension_mode    =   reg_extend_mode;
    assign  o_datamem_size      =   reg_datamem_size;
    assign  o_size_filterL      =   reg_size_filter_L;
    assign  o_zero_extend       =   reg_zero_extend;
    assign  o_lui               =   reg_lui;
    assign  o_jalR              =   reg_jalR;
    assign  o_halt              =   reg_halt;


endmodule