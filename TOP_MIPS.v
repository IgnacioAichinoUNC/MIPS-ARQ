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
        parameter   BITS_ALU_CTL        = 2,
        parameter   BITS_ALU            = 6,
        parameter   BITS_OP             = 4,
        parameter   BITS_CORTOCIRCUITO  = 3,
        parameter   SIZE_MEM_DATA       = 10,
        parameter   HW_BITS             = 16,
        parameter   BYTE_BITS_SIZE      = 8
    )
    (   
        input   wire                                i_clk,
        input   wire                                i_reset,
        input   wire                                i_ctl_clk_wiz,
        input   wire     [BITS_SIZE-1:0]            i_select_address_mem_data
        input   wire     [SIZE_INSTRUC_DEBUG-1:0]   i_select_address_mem_instr,
        input   wire     [BITS_REGS-1:0]            i_select_address_register,
        input   wire     [BITS_SIZE-1:0]            i_dato_mem_ins,
        input   wire                                i_flag_write_mem_ins,

        output  wire     [BITS_SIZE-1:0]            o_pc,
        output  wire     [BITS_SIZE-1:0]            o_data_reg_file,
        output  wire     [BITS_SIZE-1:0]            o_data_MEM_debug,
        output  wire                                o_mips_halt
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


 // ---------ID-----------------------------------------------   
    wire                            if_risk_pc_write;       //Unidad de riesgo para write en PC
    wire                            ifid_unit_risk_write;  //Riesgo de escritura
    wire                            id_unit_risk_mux;
    wire                            id_unit_risk_latch;

    //Banco de registros
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
    wire     [BITS_SIZE_CTL-1:0]    ID_ctl_instruction_op;
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
    wire                            ctl_unit_neq_branch;
    wire                            ctl_unit_branch;
    wire                            ctl_unit_mem_read;
    wire                            ctl_unit_mem_write;
    wire                            ctl_unit_alu_src;
    wire                            ctl_unit_zero_extend;
    wire                            ctl_unit_lui;

    //Mux Unidad de riesgos
    wire     [BITS_ALU_CTL-1:0]     mux_ctl_unit_alu_op;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_extend_mode;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_size_filter;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_size_filterL;
    wire                            mux_ctl_unit_mem_to_reg;
    wire                            mux_ctl_unit_register_write;
    wire                            mux_ctl_unit_halt;
    wire                            mux_ctl_unit_register_rd;
    wire                            mux_ctl_unit_jump;
    wire                            mux_ctl_unit_jal;
    wire                            mux_ctl_unit_neq_branch;
    wire                            mux_ctl_unit_branch;
    wire                            mux_ctl_unit_mem_read;
    wire                            mux_ctl_unit_mem_write;
    wire                            mux_ctl_unit_alu_src;
    wire                            mux_ctl_unit_zero_extend;
    wire                            mux_ctl_unit_lui;
    wire                            mux_ctl_unit_jal_R;
 
    
    //IDEX
    wire                            IDEX_ctl_alu_src;
    wire                            IDEX_ctl_jump;
    wire                            IDEX_ctl_JALR;
    wire                            IDEX_ctl_mem_read;
    wire     [1:0]                  IDEX_ctl_unit_alu_op;
    wire     [1:0]                  IDEX_ctl_size_filter;
    wire     [1:0]                  IDEX_ctL_size_filterL;
    wire                            IDEX_ctl_mem_to_reg;
    wire                            IDEX_ctl_register_write;
    wire                            IDEX_ctl_jal;
    wire                            IDEX_ctl_register_rd;
    wire                            IDEX_ctl_neq_branch;
    wire                            IDEX_ctl_branch;
    wire                            IDEX_ctl_mem_write;
    wire                            IDEX_ctl_zero_extend;
    wire                            IDEX_ctl_lui;

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


//--------EX--------------------------------------------
    //ALU
    wire     [BITS_SIZE-1:0]        EX_alu_result;
    wire                            EX_flag_alu_zero;
    wire     [BITS_REGS-1:0]        EX_alu_shamt;
    //Sumador branch
    wire     [BITS_SIZE-1:0]        EX_sum_pc_branch;
    //MuxShamt
    wire     [BITS_SIZE-1:0]        EX_alu_register_A;
    //Unidad cortocircuito
    wire    [BITS_CORTOCIRCUITO-1:0]   corto_register_A;
    wire    [BITS_CORTOCIRCUITO-1:0]   corto_register_B;
    //ALUControl
    wire                            EX_flag_shamt;
    wire     [BITS_OP-1:0]          EX_ctl_alu_op;
    wire     [BITS_ALU-1:0]         EX_ctl_alu_instruction;
    wire     [BITS_ALU-1:0]         EX_ctl_alu_opcode;
    //Mux Registers
    wire     [BITS_REGS-1:0]        EX_mux_register_rd;    
    //EXMEM
    wire    [BITS_SIZE-1:0]         EXMEM_PC4;
    wire    [BITS_SIZE-1:0]         EXMEM_PC8;
    wire    [BITS_SIZE-1:0]         EXMEM_PC_Branch;
    wire    [BITS_SIZE-1:0]         EXMEM_Instr;
    wire                            EXMEM_zero_alu;
    wire    [BITS_SIZE-1:0]         EXMEM_alu;    
    wire    [BITS_SIZE-1:0]         EXMEM_register2;
    wire    [BITS_REGS-1:0]         EXMEM_register_dst;
    wire    [BITS_SIZE-1:0]         EXMEM_extension;
    wire                            EXMEM_ctl_branch;
    wire                            EXMEM_ctl_neq_branch;
    wire                            EXMEM_ctl_mem_write;
    wire                            EXMEM_ctl_mem_read;
    wire                            EXMEM_ctl_mem_to_reg;
    wire                            EXMEM_ctl_register_write;
    wire    [1:0]                   EXMEM_ctl_size_filter;
    wire    [1:0]                   EXMEM_ctl_size_filterL;
    wire                            EXMEM_ctl_zero_extend;
    wire                            EXMEM_ctl_lui;
    wire                            EXMEM_ctl_halt;

//--------MEM--------------------------------------------
    wire                            MEM_PC_src_o; 
    wire    [BITS_SIZE-1:0]         MEM_dato_mem;
    wire    [BITS_SIZE-1:0]         MEM_dato_mem_Debug;
    //MEMWB  
    wire    [BITS_SIZE-1:0]         MEMWB_PC4;
    wire    [BITS_SIZE-1:0]         MEMWB_PC8;
    wire    [BITS_SIZE-1:0]         MEMWB_instruction;
    wire    [BITS_SIZE-1:0]         MEMWB_alu;
    wire    [BITS_SIZE-1:0]         MEMWB_dato_mem;
    wire    [BITS_REGS-1:0]         MEMWB_register_dst;
    wire    [BITS_SIZE-1:0]         MEMWB_extension ;
    wire                            MEMWB_ctl_jal;
    wire                            MEMWB_ctl_mem_to_reg;
    wire                            MEMWB_ctl_register_write;
    wire    [1:0]                   MEMWB_ctl_size_filterL;
    wire                            MEMWB_ctl_zero_extend ;
    wire                            MEMWB_ctl_lui ;
    wire                            MEMWB_ctl_halt ;

//-------WB--------------------------------------------
    //Multiplexor Escribir Dato
    wire    [BITS_SIZE-1:0]        WB_data_write_EX;
    //Multiplexor Memoria
    wire    [BITS_SIZE-1:0]        WB_data_write;
    wire    [BITS_REGS-1:0]        WB_register_adrr_result;






//IF
    //Memoria de instrucciones
    assign IF_IntrAddress_Debug       =   i_select_address_mem_instr;
    assign IF_Instr_Debug             =   i_dato_mem_ins;
    assign IF_flag_WriteInstr_Debug   =   i_flag_write_mem_ins;


//ID
        assign ID_Jump_i                  =   IFID_Instr[BITS_JUMP-1:0];
        //Unit Control
        assign ID_ctl_instruction_op      =   IFID_Instr[BITS_SIZE-1:BITS_SIZE-BITS_SIZE_CTL];
        assign ID_ctl_instruction_funct   =   IFID_Instr[BITS_SIZE_CTL-1:0];
        //SumadorJump
        assign EX_alu_shamt               =   IDEX_instruction [10:6];
        //Registers
        assign ID_register_rs             =   IFID_Instr[BITS_INMEDIATE+BITS_REGS+BITS_REGS-1:BITS_INMEDIATE+BITS_REGS];//BITS_INMEDIATE+RT+RS-1=16+5+5-1=25; BITS_INMEDIATE+RT=16+5=21; [25-21]
        assign ID_register_rt             =   IFID_Instr[BITS_INMEDIATE+BITS_REGS-1:BITS_INMEDIATE];//BITS_INMEDIATE+BITS_REGS-1=16+5-1=20; BITS_INMEDIATE=16; [20-16]
        assign ID_register_rd             =   IFID_Instr [BITS_INMEDIATE-1:BITS_INMEDIATE-BITS_REGS]; //BITS_INMEDIATE-1=16-1=15; BITS_INMEDIATE-RD=16-5=11; [15-11]
        assign o_data_reg_file            =   ID_data_register_Debug;
        //Extensor
        assign ID_intruct_16              =   IFID_Instr[BITS_INMEDIATE-1:0];

// EX
        //Control ALU
        assign EX_ctl_alu_instruction     =   IDEX_extension[BITS_ALU-1:0];
        assign EX_ctl_alu_opcode          =   IDEX_instruction[BITS_SIZE-1:BITS_REGS+BITS_REGS+BITS_INMEDIATE];

//MEM
        assign o_data_MEM_debug           =   MEM_dato_mem_Debug;    

        assign o_mips_halt                =   MEMWB_ctl_halt;

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
        .i_rs                       (EX_alu_register_A),
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
        .i_wb_reg_write             (MEMWB_ctl_register_write),
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
        .i_ctl_instruction_op       (ID_ctl_instruction_op),
        .i_ctl_instr_funct          (ID_ctl_instruction_funct),
        .o_register_rd              (ctl_unit_register_rd),
        .o_jump                     (ctl_unit_jump),
        .o_jal                      (ctl_unit_jal),
        .o_lui                      (ctl_unit_lui),
        .o_jalR                     (ctl_unit_jal_R),
        .o_halt                     (ctl_unit_halt),
        .o_branch                   (ctl_unit_branch),
        .o_neq_branch               (ctl_unit_neq_branch),
        .o_mem_read                 (ctl_unit_mem_read),
        .o_mem_write                (ctl_unit_mem_write),
        .o_alu_src                  (ctl_unit_alu_src),
        .o_zero_extend              (ctl_unit_zero_extend),
        .o_extension_mode           (ctl_unit_extend_mode),
        .o_mem_to_reg               (ctl_unit_mem_to_reg),
        .o_unit_alu_op              (ctl_unit_alu_op),
        .o_register_write           (ctl_unit_register_write),
        .o_size_filter              (ctl_unit_size_filter),
        .o_size_filterL             (ctl_unit_size_filterL)  
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
        .i_EXMEM_mem_read           (EXMEM_ctl_mem_read),
        .i_JALR                     (ctl_unit_jal_R),
        .i_HALT                     (ctl_unit_halt),
        .i_IDEX_rt                  (IDEX_rt),
        .i_EXMEM_rt                 (EXMEM_register_dst),
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
        .i_neq_branch               (ctl_unit_neq_branch),
        .i_mem_read                 (ctl_unit_mem_read),
        .i_mem_to_reg               (ctl_unit_mem_to_reg),
        .i_unit_alu_op              (ctl_unit_alu_op),
        .i_mem_write                (ctl_unit_mem_write),
        .i_alu_src                  (ctl_unit_alu_src),
        .i_reg_write                (ctl_unit_register_write),
        .i_extension_mode           (ctl_unit_extend_mode),
        .i_size_filter              (ctl_unit_size_filter),
        .i_size_filterL             (ctl_unit_size_filterL),
        .i_zero_extend              (ctl_unit_zero_extend),
        .i_lui                      (ctl_unit_lui),
        .i_jalR                     (ctl_unit_jal_R),
        .i_halt                     (ctl_unit_halt),


        .o_reg_dst_rd               (mux_ctl_unit_register_rd),
        .o_jump                     (mux_ctl_unit_jump),
        .o_jal                      (mux_ctl_unit_jal),
        .o_lui                      (mux_ctl_unit_lui),
        .o_jalR                     (mux_ctl_unit_jal_R),
        .o_halt                     (mux_ctl_unit_halt),
        .o_branch                   (mux_ctl_unit_branch),
        .o_neq_branch               (mux_ctl_unit_neq_branch),
        .o_mem_read                 (mux_ctl_unit_mem_read),
        .o_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .o_unit_alu_op              (mux_ctl_unit_alu_op),
        .o_mem_write                (mux_ctl_unit_mem_write),
        .o_alu_src                  (mux_ctl_unit_alu_src),
        .o_register_write           (mux_ctl_unit_register_write),
        .o_extension_mode           (mux_ctl_unit_extend_mode),
        .o_size_filter              (mux_ctl_unit_size_filter),
        .o_size_filterL             (mux_ctl_unit_size_filterL),
        .o_zero_extend              (mux_ctl_unit_zero_extend)
        
    );  

    //LATCH ID/EX
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
        .i_unit_alu_op              (mux_ctl_unit_alu_op),
        .i_reg_dst_rd               (mux_ctl_unit_register_rd),
        //ControlM
        .i_branch                   (mux_ctl_unit_branch),
        .i_neq_branch               (mux_ctl_unit_neq_branch),
        .i_mem_write                (mux_ctl_unit_mem_write),
        .i_mem_read                 (mux_ctl_unit_mem_read),
        .i_size_filter              (mux_ctl_unit_size_filter),
        //ControlWB
        .i_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .i_reg_write                (mux_ctl_unit_register_write),
        .i_size_filterL             (mux_ctl_unit_size_filterL),
        .i_zero_extend              (mux_ctl_unit_zero_extend),
        .i_lui                      (mux_ctl_unit_lui),
        .i_jalR                     (mux_ctl_unit_jal_R),
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
        .o_unit_alu_op             (IDEX_ctl_unit_alu_op),
        .o_register_rd_dst         (IDEX_ctl_register_rd),
        //ControlM
        .o_branch                  (IDEX_ctl_branch),
        .o_neq_branch              (IDEX_ctl_neq_branch),
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

//ETAPA EX
    EX
    #
    (
        .BITS_SIZE                  (BITS_SIZE),
        .BITS_REGS                  (BITS_REGS),
        .BITS_OP                    (BITS_OP),
        .BITS_CORTOCIRCUITO         (BITS_CORTOCIRCUITO)
    )
    module_EX
    (
        .i_id_extension             (IDEX_extension),
        .i_id_pc4                   (IDEX_PC4),
        .i_alu_shamt                (EX_alu_shamt),
        .i_flag_shamt               (EX_flag_shamt),
        .i_alu_op                   (EX_ctl_alu_op), 
        .i_corto_register_A         (corto_register_A),
        .i_register1                (IDEX_register1),
        .i_exmem_register           (EXMEM_alu),
        .i_wb_data_write            (WB_data_write_EX),   
        .i_idex_ctl_alu_src         (IDEX_ctl_alu_src),
        .i_corto_register_B         (corto_register_B),
        .i_register2                (IDEX_register2),
        .i_select_register          (IDEX_ctl_register_rd),
        .i_rt                       (IDEX_RT),
        .i_rd                       (IDEX_RD),
        .o_alu_zero                 (EX_flag_alu_zero),
        .o_alu_result               (EX_alu_result),
        .o_sum_pc_branch            (EX_sum_pc_branch),
        .o_data_register_A          (EX_alu_register_A),
        .o_mux_register_rd          (EX_mux_register_rd)
    );


    //Control ALU
    Control_ALU
    #(
        .BITS_ALU                   (BITS_ALU ),
        .BITS_ALU_CTL               (BITS_ALU_CTL),
        .ALU_OP                     (BITS_OP)
    )
    module_ctl_alu
    (
        .i_funct                  (EX_ctl_alu_instruction),
        .i_opcode                 (EX_ctl_alu_opcode),
        .i_unit_alu_op            (IDEX_ctl_unit_alu_op),
        .o_alu_op                 (EX_ctl_alu_op),
        .o_shamt                  (EX_flag_shamt)
    );


    //CORTOCIRCUITO
    UnitCortocircuito
    #(
        .BITS_REGS                (BITS_REGS),
        .BITS_CORTOCIRCUITO       (BITS_CORTOCIRCUITO)
    )
    Unidad_de_Cortocicuito
    (
        .i_EXMEM_register_write (EXMEM_ctl_register_write), 
        .i_EXMEM_rd             (EXMEM_register_dst),       
        .i_MEMWB_reg_write      (MEMWB_ctl_register_write),    
        .i_MEMWB_rd             (MEMWB_register_dst),      
        .i_rs                   (IDEX_RS),                  
        .i_rt                   (IDEX_RT),                 
        .o_mux_A                (corto_register_A),         
        .o_mux_B                (corto_register_B)        
    );


    //LATCH EXMEM
    EXMEM
    #(
        .BITS_SIZE              (BITS_SIZE),
        .BITS_REGS              (BITS_REGS)
    )
    module_EXMEM
    (
        //General
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_step                     (i_ctl_clk_wiz),
        .i_flush_latch              (id_unit_risk_latch),
        .i_pc4                      (IDEX_PC4),
        .i_pc8                      (IDEX_PC8),
        .i_pc_branch                (EX_sum_pc_branch),
        .i_idex_instruction         (IDEX_instruction),
        .i_flag_alu_zero            (EX_flag_alu_zero),
        .i_alu_result               (EX_alu_result),
        .i_idex_register2           (IDEX_register2),
        .i_register_dst             (EX_mux_register_rd),
        .i_idex_extension           (IDEX_extension),

        //ControlIM
        .i_jal                      (IDEX_ctl_jal),
        .i_branch                   (IDEX_ctl_branch),
        .i_neq_branch               (IDEX_ctl_neq_branch),
        .i_mem_write                (IDEX_ctl_mem_write),
        .i_mem_read                 (IDEX_ctl_mem_read),
        .i_size_filter              (IDEX_ctl_size_filter),
        
        //ControlWB
        .i_mem_to_reg               (IDEX_ctl_mem_to_reg),
        .i_reg_write                (IDEX_ctl_register_write),
        .i_size_filterL             (IDEX_ctL_size_filterL),
        .i_zero_extend              (IDEX_ctl_zero_extend),
        .i_lui                      (IDEX_ctl_lui),
        .i_halt                     (IDEX_ctl_halt),

        .o_pc4                      (EXMEM_PC4),
        .o_pc8                      (EXMEM_PC8),
        .o_pc_branch                (EXMEM_PC_Branch),
        .o_instruction              (EXMEM_Instr),
        .o_zero                     (EXMEM_zero_alu),
        .o_alu                      (EXMEM_alu),
        .o_register_2               (EXMEM_register2),
        .o_register_rd_dst          (EXMEM_register_dst),
        .o_extension                (EXMEM_extension),

        //ControlM
        .o_jal                      (EXMEM_ctl_jal),
        .o_branch                   (EXMEM_ctl_branch),
        .o_neq_branch               (EXMEM_ctl_neq_branch),
        .o_mem_write                (EXMEM_ctl_mem_write),
        .o_mem_read                 (EXMEM_ctl_mem_read),
        .o_size_filter              (EXMEM_ctl_size_filter),

        //ControlWB
        .o_mem_to_reg               (EXMEM_ctl_mem_to_reg),
        .o_register_write           (EXMEM_ctl_register_write),
        .o_size_filterL             (EXMEM_ctl_size_filterL),
        .o_zero_extend              (EXMEM_ctl_zero_extend),
        .o_lui                      (EXMEM_ctl_lui),
        .o_halt                     (EXMEM_ctl_halt)
    );    

    and_branch
    #(
    )
    module_and_branch
    (
        .i_branch       (EXMEM_ctl_branch),
        .i_neq_branch   (EXMEM_ctl_neq_branch),
        .i_zero         (EXMEM_zero_alu),
        .o_pc_source    (MEM_PC_src_o)
    );


//ETAPA MEM
    MEM
    #(
        .BITS_SIZE          (BITS_SIZE),
        .BITS_EXTENSION     (BITS_EXTENSION),
        .SIZE_MEM_DATA      (SIZE_MEM_DATA)
    )
    module_MEM
    (
        .i_clk                  (i_clk),
        .i_reset                (i_reset),
        .i_step                 (i_ctl_clk_wiz),
        .i_exmem_alu            (EXMEM_alu),
        .i_addr_mem_debug       (i_select_address_mem_data),
        .i_exmem_mem_read       (EXMEM_ctl_mem_read),
        .i_exmem_mem_write      (EXMEM_ctl_mem_write),
        .i_exmem_mem_register2  (EXMEM_register2),
        .i_exmem_size_filter    (EXMEM_ctl_size_filter),
        .o_mem_dato             (MEM_dato_mem),
        .o_mem_dato_debug       (MEM_dato_mem_Debug)
    );

    //LATCH MEMWB
    MEMWB
    #(
        .BITS_SIZE             (BITS_SIZE),
        .BITS_REGS             (BITS_REGS)
    )
    module_memwb
    (
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_step             (i_ctl_clk_wiz),
        .i_pc4              (EXMEM_PC4),
        .i_pc8              (EXMEM_PC8),
        .i_instruction      (EXMEM_Instr),
        .i_alu              (EXMEM_alu),
        .i_dato_mem         (MEM_dato_mem),
        .i_register_dst     (EXMEM_register_dst),
        .i_idex_extension   (EXMEM_extension),

        //ControlWB
        .i_mem_to_reg       (EXMEM_ctl_mem_to_reg),
        .i_reg_write        (EXMEM_ctl_register_write),
        .i_size_filterL     (EXMEM_ctl_size_filterL),
        .i_zero_extend      (EXMEM_ctl_zero_extend),
        .i_lui              (EXMEM_ctl_lui),
        .i_jal              (EXMEM_ctl_jal),
        .i_halt             (EXMEM_ctl_halt),

        .o_pc4              (MEMWB_PC4),
        .o_pc8              (MEMWB_PC8),
        .o_instruction      (MEMWB_instruction),
        .o_alu              (MEMWB_alu),
        .o_dato_mem         (MEMWB_dato_mem),
        .o_register_rd_dst  (MEMWB_register_dst),
        .o_extension        (MEMWB_extension),

        //ControlWB
        .o_mem_to_reg       (MEMWB_ctl_mem_to_reg),
        .o_register_write   (MEMWB_ctl_register_write),
        .o_size_filterL     (MEMWB_ctl_size_filterL),
        .o_zero_extend      (MEMWB_ctl_zero_extend),
        .o_lui              (MEMWB_ctl_lui),
        .o_jal              (MEMWB_ctl_jal),
        .o_halt             (MEMWB_ctl_halt)
    );

    WB 
    #(
        .BITS_SIZE          (BITS_SIZE),       
        .HW_BITS            (HW_BITS),
        .BYTE_BITS_SIZE     (BYTE_BITS_SIZE),
        .BITS_REGS          (BITS_REGS),      
        .BITS_EXTENSION     (BITS_EXTENSION)
    )
    module_WB   
    (
        .i_memwb_lui            (MEMWB_ctl_lui),
        .i_memwb_extension      (MEMWB_extension),
        .i_memwb_dato_mem       (MEMWB_dato_mem),
        .i_memwb_size_filterL   (MEMWB_ctl_size_filterL),
        .i_memwb_zero_extend    (MEMWB_ctl_zero_extend),
        .i_memwb_mem_to_reg     (MEMWB_ctl_mem_to_reg),
        .i_memwb_alu            (MEMWB_alu),
        .i_memwb_jal            (MEMWB_ctl_jal),
        .i_memwb_pc8            (MEMWB_PC8),
        .i_memwb_register_dst   (MEMWB_register_dst),
        .o_wb_data_write_ex     (WB_data_write_EX),
        .o_wb_data_write        (WB_data_write),
        .o_wb_register_adrr_result(WB_register_adrr_result)
    );

endmodule