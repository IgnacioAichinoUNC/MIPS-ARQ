`timescale 1ns / 1ps

//module MIPS
module TOP_MIPS
    #(
        parameter   BITS_SIZE           = 32,
        parameter   SIZE_MEM_INSTRUC    = 256,
        parameter   SIZE_INSTRUC_DEBUG  = 8
        
    )
    (   
        input   wire                                i_clk,
        input   wire                                i_reset,
        input   wire                                i_ctl_clk_wiz,
        input   wire     [SIZE_INSTRUC_DEBUG-1:0]   i_select_address_mem_instr,
        input   wire     [BITS_SIZE-1:0]            i_dato_mem_ins,
        input   wire                                i_flag_write_mem_ins,
        output  wire     [BITS_SIZE-1:0]            o_pc
    );

// ---------IF-----------------------------------------------
//PC
    wire    [BITS_SIZE-1:0]        IF_PC4_o;
    wire    [BITS_SIZE-1:0]        IF_PC8_o;
//Memoria de instrucciones
    wire    [BITS_SIZE-1:0]        IF_Instr;
    wire    [BITS_SIZE-1:0]        IF_Instr_Debug;
    wire    [BITS_SIZE-1:0]        IF_IntrAddress_Debug;
//IF_ID  
    wire    [BITS_SIZE-1:0]        IFID_PC4;
    wire    [BITS_SIZE-1:0]        IFID_PC8;
    wire    [BITS_SIZE-1:0]        IFID_Instr;





 // ---------ID-----------------------------------------------    //Implementar en modulo, solo sirve ahora en debug  
// Unidad Riesgos
    wire                            if_risk_pc_write;       //Unidad de riesgo para write en PC
    wire                            ifid_unit_risk_write;  //Riesgo de escritura
// ---------IDEX----------------------------------------------- //Implementar en modulo, solo sirve ahora en debug  
//ID/EX/CONTROL
    wire                            IDEX_ctl_alu_src;
    wire                            IDEX_ctl_jump;
    wire                            IDEX_ctl_JALR;
//ID_EX
    wire    [BITS_SIZE-1:0]         IDEX_DJump;



//--------EX/MEM---------------------------
    wire    [BITS_SIZE-1:0]         EXMEM_PC_Branch;
//MEM
    wire                            MEM_PC_src_o; 



//--------EX/MEM---------------------------
//MuxShamt
    wire     [BITS_SIZE-1:0]        EX_alu_regA;




    //Memoria de instrucciones
    assign IF_IntrAddress_Debug       =   i_select_address_mem_instr;
    assign IF_Instr_Debug             =   i_dato_mem_ins;
    assign IF_flag_WriteInstr_Debug   =   i_flag_write_mem_ins;

//ETAPA IF
    IF
    #(
        .BITS_SIZE                  (BITS_SIZE),
        .SIZE_TOTAL                 (SIZE_MEM_INSTRUC)
    )
    module_IF
    (
        .i_clk                      (i_clk),
        .i_step                     (i_ctl_clk_wiz),
        .i_reset                    (i_reset),
        .i_hazard_pc_write          (if_risk_pc_write),
        .i_instruction_address      (IF_IntrAddress_Debug),
        .i_instruction              (IF_Instr_Debug),
        .i_flag_write_intruc        (IF_flag_WriteInstr_Debug),
        .i_is_jump                  (IDEX_ctl_jump),
        .i_is_JALR                  (IDEX_ctl_JALR),
        .i_pc_source                (MEM_PC_src_o),
        .i_suma_branch              (EXMEM_PC_Branch),
        .i_suma_jump                (IDEX_DJump),
        .i_rs                       (EX_alu_regA),
        .o_IF_PC4                   (IF_PC4_o),
        .o_IF_PC                    (o_pc),
        .o_instruction              (IF_Instr),
        .o_IF_PC8                   (IF_PC8_o)     
    );


///LATCH IF/ID
    IFID
    #(
        .BITS_SIZE                  (BITS_SIZE)
    )
    module_IFID
    (
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_step                     (i_ctl_clk_wiz),
        .i_IFID_unit_risk_write     (ifid_unit_risk_write),
        .i_pc4                      (IF_PC4_o),
        .i_pc8                      (IF_PC8_o),
        .i_instruction              (IF_Instr),
        .o_pc4                      (IFID_PC4),
        .o_pc8                      (IFID_PC8),
        .o_instruction              (IFID_Instr)
    );




endmodule