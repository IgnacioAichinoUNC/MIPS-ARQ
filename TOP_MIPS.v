`timescale 1ns / 1ps

//module MIPS
module TOP_MIPS
    #(
        parameter   BITS_SIZE           = 32,
        parameter   SIZE_MEM_INSTRUC    = 256,
        parameter   SIZE_INSTRUC_DEBUG  = 8,

        parameter   BITS_JUMP           = 26,
        parameter   BITS_REGS           = 5,
        parameter   REG_SIZE            = 32,
        parameter   BITS_INMEDIATE      = 16,
        parameter   BITS_EXTENSION      = 2,
        parameter   BITS_SIZE_CTL       = 6,
        parameter   BITS_ALU_CTL        = 2
    )
    (   
        input   wire                                i_clk,
        input   wire                                i_reset,
        input   wire                                i_ctl_clk_wiz,
        input   wire     [SIZE_INSTRUC_DEBUG-1:0]   i_select_address_mem_instr,
        input   wire     [BITS_SIZE-1:0]            i_dato_mem_ins,
        input   wire                                i_flag_write_mem_ins,
        
        input   wire     [BITS_REGS-1:0]            i_select_address_register,

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
    wire                            id_unit_risk_mux;
    wire                            id_unit_risk_latch;


// Banco de registros
    wire     [BITS_REGS-1:0]        ID_register_rs;
    wire     [BITS_REGS-1:0]        ID_register_rt;
    wire     [BITS_REGS-1:0]        ID_register_rd;
    wire     [BITS_SIZE-1:0]        ID_data_rs;
    wire     [BITS_SIZE-1:0]        ID_data_rt;
    wire     [BITS_SIZE-1:0]        ID_data_register_Debug;
//Extensor de signo
    wire     [BITS_INMEDIATE-1:0]   ID_intruct_16;
    wire     [BITS_SIZE-1:0]        ID_intruct_ext;
//Sumador PC Jump 
    wire     [BITS_JUMP-1:0]        ID_JUMP_i;
    wire     [BITS_SIZE-1:0]        ID_JUMP_o;
//Unidad de control
    wire     [BITS_SIZE_CTL-1:0]    ID_ctl_instruction;
    wire     [BITS_SIZE_CTL-1:0]    ID_ctl_instruction_funct;
    wire     [BITS_ALU_CTL-1:0]     ctl_unit_alu_op;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_extend_mode;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_size_filter;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_size_filterL;
    wire                            ctl_unit_mem_to_reg;
    wire                            ctl_unit_register_write;
    wire                            ctl_unit_jal_R;
    wire                            ctl_unit_halt;
    wire                            ctl_unit_register_rd;
    wire                            ctl_unit_jump;
    wire                            ctl_unit_jal;
    wire                            ctl_unit_new_branch;
    wire                            ctl_unit_branch;
    wire                            ctl_unit_mem_read;
    wire                            ctl_unit_mem_write;
    wire                            ctl_unit_alu_src;
    wire                            ctl_unit_zero_extend;
    wire                            ctl_unit_lui;
    wire                            ctl_unit_jalR;
    wire                            ctl_unit_halt;
//Mux Unidad de riesgos
    wire     [BITS_ALU_CTL-1:0]     mux_ctl_unit_alu_op;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_extend_mode;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_size_filter;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_size_filterL;
    wire                            mux_ctl_unit_mem_to_reg;
    wire                            mux_ctl_unit_register_write;
    wire                            mux_ctl_unit_jal_R;
    wire                            mux_ctl_unit_halt;
    wire                            mux_ctl_unit_register_rd;
    wire                            mux_ctl_unit_jump;
    wire                            mux_ctl_unit_jal;
    wire                            mux_ctl_unit_new_branch;
    wire                            mux_ctl_unit_branch;
    wire                            mux_ctl_unit_mem_read;
    wire                            mux_ctl_unit_mem_write;
    wire                            mux_ctl_unit_alu_src;
    wire                            mux_ctl_unit_zero_extend;
    wire                            mux_ctl_unit_lui;
    wire                            mux_ctl_unit_jalR;
    wire                            mux_ctl_unit_halt;
    

// ---------IDEX--
//CONTROL
    wire                            IDEX_ctl_alu_src;
    wire                            IDEX_ctl_jump;
    wire                            IDEX_ctl_JALR;
    wire                            IDEX_ctl_mem_read;
    wire     [BITS_ALU_CTL-1:0]     IDEX_ctl_alu_op;
    wire     [BITS_EXTENSION-1:0]   IDEX_ctl_size_filter;
    wire     [BITS_EXTENSION-1:0]   IDEX_ctL_size_filterL;
    wire                            IDEX_ctl_mem_to_reg;
    wire                            IDEX_ctl_register_write;
    wire                            IDEX_ctl_jal;
    wire                            IDEX_ctl_halt;
    wire                            IDEX_ctl_register_rd;
    wire                            IDEX_ctl_new_branch;
    wire                            IDEX_ctl_branch;
    wire                            IDEX_ctl_mem_write;
    wire                            IDEX_ctl_zero_extend;
    wire                            IDEX_ctl_lui;
    wire                            IDEX_ctl_halt;

    wire    [BITS_SIZE-1:0]         IDEX_extension;
    wire    [BITS_SIZE-1:0]         IDEX_instruction;
    wire    [BITS_SIZE-1:0]         IDEX_PC4;
    wire    [BITS_SIZE-1:0]         IDEX_PC8;
    wire    [BITS_REGS-1:0]         IDEX_RS;
    wire    [BITS_REGS-1:0]         IDEX_RT;
    wire    [BITS_REGS-1:0]         IDEX_RD;
    wire    [BITS_SIZE-1:0]         IDEX_DJump;
    wire    [BITS_SIZE-1:0]         IDEX_register1;
    wire    [BITS_SIZE-1:0]         IDEX_register2;



//--------EX/MEM---------------------------
    wire    [BITS_SIZE-1:0]         EXMEM_PC_Branch;
    wire                            EXMEM_mem_Read;
//MEM
    wire                            MEM_PC_src_o; 

//MEM_W 
    wire                            MEM_WB_register_write;
    wire    [BITS_REGS-1:0]         WB_register_adrr_result;
    //MultiplexorEscribirDato
    wire    [BITS_SIZE-1:0]         WB_data_write;





//--------EX/MEM--
//MuxShamt
    wire     [BITS_SIZE-1:0]        EX_alu_regA;
    wire     [BITS_REGS-1:0]        EXMEM_register_addr_result;






    //Memoria de instrucciones
    assign IF_IntrAddress_Debug       =   i_select_address_mem_instr;
    assign IF_Instr_Debug             =   i_dato_mem_ins;
    assign IF_flag_WriteInstr_Debug   =   i_flag_write_mem_ins;


        //ID
        assign ID_Jump_i                  =   IFID_Instr[BITS_JUMP-1:0];
        //Unit Control
        assign ID_ctl_instruction         =   IFID_Instr[BITS_SIZE-1:BITS_SIZE-BITS_SIZE_CTL];
        assign ID_ctl_instruction_funct   =   IFID_Instr[BITS_SIZE_CTL-1:0];
        //Registers
        assign ID_register_rs             =   IFID_Instr[BITS_INMEDIATE+BITS_REGS+BITS_REGS-1:BITS_INMEDIATE+BITS_REGS];//BITS_INMEDIATE+RT+RS-1=16+5+5-1=25; BITS_INMEDIATE+RT=16+5=21; [25-21]
        assign ID_register_rt             =   IFID_Instr[BITS_INMEDIATE+BITS_REGS-1:BITS_INMEDIATE];//BITS_INMEDIATE+BITS_REGS-1=16+5-1=20; BITS_INMEDIATE=16; [20-16]
        assign ID_register_rd             =   IFID_Instr [BITS_INMEDIATE-1:BITS_INMEDIATE-BITS_REGS]; //BITS_INMEDIATE-1=16-1=15; BITS_INMEDIATE-RD=16-5=11; [15-11]
        //Extensor
        assign ID_intruct_16              =   IFID_Instr[BITS_INMEDIATE-1:0];


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


//ETAPA ID
    ID
    #(
        .BITS_SIZE                  (BITS_SIZE),
        .BITS_JUMP                  (BITS_JUMP),
        .BITS_REGS                  (BITS_REGS),
        .REG_SIZE                   (REG_SIZE),
        .BITS_INMEDIATE             (BITS_INMEDIATE),
        .BITS_EXTENSION             (BITS_EXTENSION)
    )
    module_ID
    (
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_step                     (i_ctl_clk_wiz),
        .i_wb_reg_write             (MEM_WB_register_write),
        .i_addr_rs                  (ID_register_rs),
        .i_addr_rt                  (ID_register_rt),
        .i_wb_addr_rd               (WB_register_adrr_result),
        .i_tx_adrr_reg_unitdebug    (i_select_address_register),
        .i_wb_data                  (WB_data_write),

        .i_IFID_JUMP                (ID_Jump_i),
        .i_IDEX_PC4                 (IDEX_PC4),
        .i_id_inmediate             (ID_intruct_16),
        .i_rctrl_extensionmode      (ctl_unit_extend_mode),
        .o_rs                       (ID_data_rs),
        .o_rt                       (ID_data_rt),
        .o_data_tx_debug            (ID_data_register_Debug),
        .o_ID_JUMP                  (ID_JUMP_o),
        .o_extension_result         (ID_intruct_ext) 
    );

//Unidad de Control
    UnitControl
    #(
        .BITS_SIZE                 (BITS_SIZE_CTL)
    )
    Unidad_de_Control
    (
        .i_ctl_instruction          (ID_ctl_instruction),
        .i_ctl_instr_funct          (ID_ctl_instruction_funct),
        .o_register_rd              (ctl_unit_register_rd),
        .o_jump                     (ctl_unit_jump),
        .o_jal                      (ctl_unit_jal),
        .o_lui                      (ctl_unit_lui),
        .o_jalR                     (ctl_unit_jal_R),
        .o_halt                     (ctl_unit_halt),
        .o_branch                   (ctl_unit_new_branch),
        .o_new_branch               (ctl_unit_branch),
        .o_mem_read                 (ctl_unit_mem_read),
        .o_mem_write                (ctl_unit_mem_write),
        .o_alu_src                  (ctl_unit_alu_src),
        .o_zero_extend              (ctl_unit_zero_extend),
        .o_extension_mode           (ctl_unit_extend_mode),
        .o_mem_to_reg               (ctl_unit_mem_to_reg),
        .o_alu_op                   (ctl_unit_alu_op),
        .o_register_write           (ctl_unit_register_write),
        .o_size_filter              (ctl_unit_size_filter),
        .o_size_filterL             (ctl_unit_size_filter_L)  
    );

//Unidad de Riegos
    UnitRisk
    #(
        .BITS_REGS                  (BITS_REGS)
    )
    Unidad_de_Riesgos
    (
        .i_EXMEM_flush              (MEM_PC_src_o),
        .i_IDEX_mem_read            (IDEX_ctl_mem_read),
        .i_EXMEM_mem_read           (EXMEM_mem_Read),
        .i_JALR                     (ctl_unit_jal_R),
        .i_HALT                     (ctl_unit_halt),
        .i_IDEX_rt                  (IDEX_rt),
        .i_EXMEM_rt                 (EXMEM_register_addr_result),
        .i_IFID_rs                  (ID_register_rs),
        .i_IFID_rt                  (ID_register_rt),
        .o_risk_mux                 (id_unit_risk_mux),
        .o_pc_write                 (if_risk_pc_write),
        .o_IFID_write               (ifid_unit_risk_write),
        .o_flush_latch              (id_unit_risk_latch)
    );

//Mux
    mux_unit_risk
    #(
    )
    ID_Mux_Unit_Risk
    (
        .i_risk                     (id_unit_risk_mux),
        .i_reg_dst_rd               (ctl_unit_register_rd),
        .i_jump                     (ctl_unit_jump),
        .i_jal                      (ctl_unit_jal),
        .i_branch                   (ctl_unit_branch),
        .i_new_branch               (ctl_unit_new_branch),
        .i_mem_read                 (ctl_unit_mem_read),
        .i_mem_to_reg               (ctl_unit_mem_to_reg),
        .i_alu_op                   (ctl_unit_alu_op),
        .i_mem_write                (ctl_unit_mem_write),
        .i_alu_src                  (ctl_unit_alu_src),
        .i_reg_write                (ctl_unit_register_write),
        .i_extension_mode           (ctl_unit_extend_mode),
        .i_size_filter              (ctl_unit_size_filter),
        .i_size_filterL             (ctl_unit_size_filterL),
        .i_zero_extend              (ctl_unit_zero_extend),
        .i_lui                      (ctl_unit_lui),
        .i_jalR                     (ctl_unit_jalR),
        .i_halt                     (ctl_unit_halt),


        .o_reg_dst_rd               (mux_ctl_unit_register_rd),
        .o_jump                     (mux_ctl_unit_jump),
        .o_jal                      (mux_ctl_unit_jal),
        .o_lui                      (mux_ctl_unit_lui),
        .o_jalR                     (mux_ctl_unit_jalR),
        .o_halt                     (mux_ctl_unit_halt)
        .o_branch                   (mux_ctl_unit_branch),
        .o_new_branch               (mux_ctl_unit_new_branch),
        .o_mem_read                 (mux_ctl_unit_mem_read),
        .o_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .o_alu_op                   (mux_ctl_unit_alu_op),
        .o_mem_write                (mux_ctl_unit_mem_write),
        .o_alu_src                  (mux_ctl_unit_alu_src),
        .o_register_write           (mux_ctl_unit_register_write),
        .o_extension_mode           (mux_ctl_unit_extend_mode),
        .o_size_filter              (mux_ctl_unit_size_filter),
        .o_size_filterL             (mux_ctl_unit_size_filterL),
        .o_zero_extend              (mux_ctl_unit_zero_extend),
        
    );  

    // ETAPA ID/EX
    IDEX
    #(
        .BITS_SIZE                  (BITS_SIZE),
        .BITS_REGS                  (BITS_REGS)
    )
    module_IDEX
    (
        //General
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_step                     (i_ctl_clk_wiz),
        .i_flush_latch              (id_unit_risk_latch),
        .i_pc4                      (IFID_PC4),
        .i_pc8                      (IFID_PC8),
        .i_instruction              (IFID_Instr),

        //ControlEX
        .i_jump                     (mux_ctl_unit_jump),
        .i_jal                      (mux_ctl_unit_jal),
        .i_alu_src                  (mux_ctl_unit_alu_src),
        .i_alu_op                   (mux_ctl_unit_alu_op),
        .i_reg_dst_rd               (mux_ctl_unit_register_rd),
        //ControlM
        .i_branch                   (mux_ctl_unit_branch),
        .i_new_branch               (mux_ctl_unit_new_branch),
        .i_mem_write                (mux_ctl_unit_mem_write),
        .i_mem_read                 (mux_ctl_unit_mem_read),
        .i_size_filter              (mux_ctl_unit_size_filter),
        //ControlWB
        .i_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .i_reg_write                (mux_ctl_unit_register_write),
        .i_size_filterL             (mux_ctl_unit_size_filterL),
        .i_zero_extend              (mux_ctl_unit_zero_extend),
        .i_lui                      (mux_ctl_unit_lui),
        .i_jalR                     (mux_ctl_unit_jalR),
        .i_halt                     (mux_ctl_unit_halt),

        //idex
        .i_data_rs                 (ID_data_rs),
        .i_register_data_2         (ID_data_rt),
        .i_extension               (ID_intruct_ext),
        .i_rs                      (ID_register_rs),
        .i_rt                      (ID_register_rt),
        .i_rd                      (ID_register_rd),
        .i_DJump                   (ID_Jump_o),
        .o_pc4                     (IDEX_PC4),
        .o_pc8                     (IDEX_PC8),
        .o_instruction             (IDEX_instruction),
        .o_register_1              (IDEX_register1),
        .o_register_2              (IDEX_register2),
        .o_extension               (IDEX_extension),
        .o_rs                      (IDEX_RS),
        .o_rt                      (IDEX_RT),   
        .o_rd                      (IDEX_RD),
        .o_DJump                   (IDEX_DJump),

        //ControlEX
        .o_jump                    (IDEX_ctl_jump),
        .o_jalR                    (IDEX_ctl_JALR),
        .o_jal                     (IDEX_ctl_jal),
        .o_alu_src                 (IDEX_ctl_alu_src),
        .o_alu_op                  (IDEX_ctl_alu_op),
        .o_register_rd_dst         (IDEX_ctl_register_rd),
        //ControlM
        .o_branch                  (IDEX_ctl_branch),
        .o_new_branch              (IDEX_ctl_new_branch),
        .o_mem_write               (IDEX_ctl_mem_write),
        .o_mem_read                (IDEX_ctl_mem_read),
        .o_size_filter             (IDEX_ctl_size_filter),
        //ControlWB
        .o_mem_to_reg              (IDEX_ctl_mem_to_reg),
        .o_register_write          (IDEX_ctl_register_write),
        .o_size_filterL            (IDEX_ctL_size_filterL),
        .o_zero_extend             (IDEX_ctl_zero_extend),
        .o_lui                     (IDEX_ctl_lui),
        .o_halt                    (IDEX_ctl_halt)
    );


endmodule