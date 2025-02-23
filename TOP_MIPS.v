`timescale 1ns / 1ps

//module MIPS
module TOP_MIPS
    #(
        parameter   BITS_SIZE           = 32,
        parameter   SIZE_MEM_INSTRUC    = 256, // 64
        parameter   SIZE_INSTRUC_DEBUG  = 8,
        parameter   SIZE_MEM_DATA       = 16,
        parameter   BITS_JUMP           = 26,
        parameter   BITS_INMEDIATE      = 16,
        parameter   BITS_EXTENSION      = 2,
        parameter   BITS_SIZE_CTL       = 6,
        parameter   BITS_ALU            = 6,
        parameter   BITS_ALU_CTL        = 2,
        parameter   BITS_OP             = 4,
        parameter   HW_BITS             = 16,
        parameter   BYTE_SIZE           = 8,
        parameter   BITS_REGS           = 5,
        parameter   BITS_CORTOCIRCUITO  = 3
        
    )
    (
        input   wire                                i_clk,
        input   wire                                i_reset,
        input   wire                                i_ctl_clk_wiz,
        input   wire     [BITS_SIZE-1:0]            i_select_address_mem_data,
        input   wire     [SIZE_INSTRUC_DEBUG-1:0]   i_select_address_mem_instr,
        input   wire     [BITS_REGS-1:0]            i_select_address_register,
        input   wire     [BITS_SIZE-1:0]            i_dato_mem_ins,
        input   wire                                i_flag_write_mem_ins,

        output  wire     [BITS_SIZE-1:0]            o_pc,
        output  wire     [BITS_SIZE-1:0]            o_data_register,
        output  wire     [BITS_SIZE-1:0]            o_data_MEM_debug,
        output  wire                                o_mips_halt,

        output  wire     [BITS_SIZE-1:0]            o_IFID_instruct,
        output  wire     [BITS_SIZE-1:0]            o_ID_JUMP,
        output  wire     [BITS_SIZE-1:0]            o_ID_PC_BRANCH,
        output  wire     [BITS_SIZE-1:0]            o_IDEX_instruct,
        output  wire     [BITS_SIZE-1:0]            o_IDEX_dato_rs,
        output  wire     [BITS_SIZE-1:0]            o_IDEX_dato_rt,
        output  wire     [BITS_SIZE-1:0]            o_IDEX_extend,
        output  wire     [BITS_SIZE-1:0]            o_EXMEM_instruc,
        output  wire     [BITS_SIZE-1:0]            o_EXMEM_alu_result,
        output  wire     [BITS_SIZE-1:0]            o_EXMEM_dato_rt,
        output  wire     [BITS_SIZE-1:0]            o_EXMEM_extend,
        output  wire     [BITS_SIZE-1:0]            o_MEMWB_instruct,
        output  wire     [BITS_SIZE-1:0]            o_MEMWB_alu_result,
        output  wire     [BITS_SIZE-1:0]            o_MEMWB_datamem,
        output  wire     [BITS_SIZE-1:0]            o_MEMWB_extend
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

    wire    [BITS_SIZE-1:0]         wire_muxPC_ID;
    wire    [BITS_SIZE-1:0]         ID_PC_BRANCH;

     //Banco de registros
    wire     [BITS_REGS-1:0]        ID_register_rs;
    wire     [BITS_REGS-1:0]        ID_register_rt;
    wire     [BITS_REGS-1:0]        ID_register_rd;
    wire     [BITS_SIZE-1:0]        ID_data_rs;
    wire     [BITS_SIZE-1:0]        ID_data_rt;
    wire     [BITS_SIZE-1:0]        ID_data_register_Debug;
    // Unidad Control
    wire     [BITS_SIZE_CTL-1:0]    ID_ctl_instruction_op;
    wire     [BITS_SIZE_CTL-1:0]    ID_ctl_instruction_funct;
    wire     [BITS_ALU_CTL-1:0]     ctl_unit_alu_op;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_extend_mode;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_size_filter;
    wire     [BITS_EXTENSION-1:0]   ctl_unit_data_load_size;
    wire                            ctl_unit_branch;
    wire                            ctl_unit_neq_branch;
    wire                            ctl_unit_register_write;
    wire                            ctl_unit_mem_to_reg;
    wire                            ctl_unit_jump;
    wire                            ctl_unit_jal;
    wire                            ctl_unit_jal_R;
    wire                            ctl_unit_register_rd;
    wire                            ctl_unit_alu_src;
    wire                            ctl_unit_mem_read;
    wire                            ctl_unit_mem_write;
    wire                            ctl_unit_zero_extend;
    wire                            ctl_unit_lui;
    wire                            ctl_unit_halt;
    //Sumador PC Jump 
    wire     [BITS_JUMP-1:0]        ID_JUMP_i;
    wire     [BITS_SIZE-1:0]        ID_JUMP_o;
    //Extensor de signo
    wire     [BITS_INMEDIATE-1:0]   ID_intruct_16;
    wire     [BITS_SIZE-1:0]        ID_intruct_ext;
    //Mux Unidad Riesgos
    wire     [BITS_ALU_CTL-1:0]     mux_ctl_unit_alu_op;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_extend_mode;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_dato_mem_size;
    wire     [BITS_EXTENSION-1:0]   mux_ctl_unit_data_load_size;
    wire                            mux_ctl_unit_register_write;
    wire                            mux_ctl_unit_mem_to_reg;
    wire                            mux_ctl_unit_branch;
    wire                            mux_ctl_unit_neq_branch;
    wire                            mux_ctl_unit_jump;
    wire                            mux_ctl_unit_jal;
    wire                            mux_ctl_unit_register_rd;
    wire                            mux_ctl_unit_alu_src;
    wire                            mux_ctl_unit_mem_read;
    wire                            mux_ctl_unit_mem_write;
    wire                            mux_ctl_unit_zero_extend;
    wire                            mux_ctl_unit_lui;
    wire                            mux_ctl_unit_jal_R;
    wire                            mux_ctl_unit_halt;
    //IDEX
    wire    [BITS_SIZE-1:0]         IDEX_PC4;
    wire    [BITS_SIZE-1:0]         IDEX_PC8;
    wire    [BITS_SIZE-1:0]         IDEX_register1;
    wire    [BITS_SIZE-1:0]         IDEX_register2;
    wire    [BITS_REGS-1:0]         IDEX_RS;
    wire    [BITS_REGS-1:0]         IDEX_RT;
    wire    [BITS_REGS-1:0]         IDEX_RD;
    wire    [BITS_SIZE-1:0]         IDEX_DJump;
    wire    [BITS_SIZE-1:0]         IDEX_extension;
    wire    [BITS_SIZE-1:0]         IDEX_instruction;
    wire                            IDEX_ctl_alu_src;
    wire                            IDEX_ctl_jump;
    wire                            IDEX_ctl_jal;
    wire    [1:0]                   IDEX_ctl_unit_alu_op;
    wire                            IDEX_ctl_register_rd;
    wire                            IDEX_ctl_branch;
    wire                            IDEX_ctl_neq_branch;
    wire                            IDEX_ctl_mem_write;
    wire                            IDEX_ctl_mem_read;
    wire                            IDEX_ctl_mem_to_reg;
    wire                            IDEX_ctl_register_write;
    wire                            IDEX_ctl_lui;
    wire                            IDEX_ctl_JALR;
    wire                            IDEX_ctl_halt;
    wire    [1:0]                   IDEX_ctl_datomem_size;
    wire    [1:0]                   IDEX_ctL_dataload_size;
    wire                            IDEX_ctl_zero_extend;


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
    wire    [1:0]                   EXMEM_ctl_datomem_size;
    wire    [1:0]                   EXMEM_ctL_dataload_size;
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
    wire    [1:0]                   MEMWB_ctL_dataload_size;
    wire                            MEMWB_ctl_zero_extend;
    wire                            MEMWB_ctl_lui;
    wire                            MEMWB_ctl_halt;


//-------WB--------------------------------------------
    //Multiplexor Escribir Dato
    wire    [BITS_SIZE-1:0]        WB_data_write_EX;
    //Multiplexor Memoria
    wire    [BITS_REGS-1:0]        WB_register_adrr_result;
    wire    [BITS_SIZE-1:0]        WB_data_write;

//IF

    //Memoria de instrucciones
    assign IF_IntrAddress_Debug     =   i_select_address_mem_instr;
    assign IF_Instr_Debug           =   i_dato_mem_ins;
    assign IF_flag_WriteInstr_Debug =   i_flag_write_mem_ins;

//ID
    assign ID_ctl_instruction_op    =    IFID_Instr[BITS_SIZE-1:BITS_SIZE-BITS_SIZE_CTL];
    assign ID_ctl_instruction_funct =    IFID_Instr[BITS_SIZE_CTL-1:0] ;
    assign ID_JUMP_i                =    IFID_Instr[BITS_JUMP-1:0] ;
    //Registros
    assign ID_register_rs           =    IFID_Instr[BITS_INMEDIATE+BITS_REGS+BITS_REGS-1:BITS_INMEDIATE+BITS_REGS];//BITS_INMEDIATE+RT+RS-1=16+5+5-1=25; BITS_INMEDIATE+RT=16+5=21; [25-21]
    assign ID_register_rt           =    IFID_Instr[BITS_INMEDIATE+BITS_REGS-1:BITS_INMEDIATE];//BITS_INMEDIATE+RT-1=16+5-1=20; BITS_INMEDIATE=16; [20-16]
    assign ID_register_rd           =    IFID_Instr[BITS_INMEDIATE-1:BITS_INMEDIATE-BITS_REGS]; //BITS_INMEDIATE-1=16-1=15; BITS_INMEDIATE-RD=16-5=11; [15-11]

    //SumadorJump
    assign EX_alu_shamt             =    IDEX_instruction[10:6];
    //Extensor
    assign ID_intruct_16            =   IFID_Instr[BITS_INMEDIATE-1:0];
    
//EX
    //Control ALU
    assign EX_ctl_alu_instruction   =   IDEX_extension[BITS_ALU-1:0];
    assign EX_ctl_alu_opcode        =   IDEX_instruction[BITS_SIZE-1:BITS_REGS+BITS_REGS+BITS_INMEDIATE];
    assign o_EXMEM_instruc          =   EXMEM_Instr;
    assign o_EXMEM_alu_result       =   EXMEM_alu;
    assign o_EXMEM_dato_rt          =   EXMEM_register2;
    assign o_EXMEM_extend           =   EXMEM_extension;

    //OUTPUT
    assign o_IFID_instruct          =   IFID_Instr;
    assign o_ID_JUMP                =   ID_JUMP_o;
    assign o_ID_PC_BRANCH           =   ID_PC_BRANCH;
    assign o_data_register          =   ID_data_register_Debug;
    assign o_IDEX_instruct          =   IDEX_instruction;
    assign o_IDEX_dato_rs           =   IDEX_register1;
    assign o_IDEX_dato_rt           =   IDEX_register2;
    assign o_IDEX_extend            =   IDEX_extension;
    assign o_MEMWB_instruct         =   MEMWB_instruction;
    assign o_MEMWB_alu_result       =   MEMWB_alu;
    assign o_MEMWB_datamem          =   MEMWB_dato_mem;
    assign o_MEMWB_extend           =   MEMWB_extension;
    assign o_data_MEM_debug         =   MEM_dato_mem_Debug; 
    assign o_mips_halt              =   MEMWB_ctl_halt;
   

//ETAPA IF
    IF#(
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
        .i_mux_pc_o                 (wire_muxPC_ID),
        //.i_is_jump                  (IDEX_ctl_jump),
        //.i_is_JALR                  (IDEX_ctl_JALR),
        //.i_pc_source                (MEM_PC_src_o),
        //.i_suma_branch              (EXMEM_PC_Branch),
        //.i_suma_jump                (ID_JUMP_o),
        //.i_rs                       (EX_alu_register_A),
        .o_IF_PC4                   (IF_PC4_o),
        .o_IF_PC                    (o_pc),
        .o_instruction              (IF_Instr),
        .o_IF_PC8                   (IF_PC8_o)     
    );

    ///LATCH IF/ID
    IFID#(
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
    ID  #(
        .BITS_SIZE              (BITS_SIZE),
        .BITS_JUMP              (BITS_JUMP),
        .BITS_REGS              (BITS_REGS),
        .REG_SIZE               (BITS_SIZE),
        .BITS_INMEDIATE         (BITS_INMEDIATE),
        .BITS_EXTENSION         (BITS_EXTENSION)
    )
    module_ID
    (
        .i_clk                  (i_clk),
        .i_reset                (i_reset),
        .i_step                 (i_ctl_clk_wiz),
        .i_flag_wb_reg_write    (MEMWB_ctl_register_write),
        .i_addr_rs              (ID_register_rs),
        .i_addr_rt              (ID_register_rt),
        .i_tx_adrr_reg_unitdebug (i_select_address_register),
        .i_wb_addr_rd           (WB_register_adrr_result),
        .i_wb_data              (WB_data_write),
        .i_IFID_JUMP            (ID_JUMP_i),
        .i_IFID_PC4             (IFID_PC4),
        .i_id_inmediate         (ID_intruct_16),
        .i_ctl_extension_mode   (ctl_unit_extend_mode),

        .i_is_jump              (ctl_unit_jump),
        .i_is_JALR              (ctl_unit_jal_R),
        .i_branch               (ctl_unit_branch),
        .i_neq_branch           (ctl_unit_neq_branch),

        .o_rs                   (ID_data_rs),
        .o_rt                   (ID_data_rt),
        .o_data_tx_debug        (ID_data_register_Debug),
        .o_ID_JUMP              (ID_JUMP_o),
        .o_extension_result     (ID_intruct_ext),
        .o_ID_PC_BRANCH         (ID_PC_BRANCH),  
        .o_wire_IF_PC           (wire_muxPC_ID)
    );


    //Unidad de Control
    UnitControl#(
        .BITS_SIZE                  (BITS_SIZE_CTL)
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
        .o_branch                   (ctl_unit_branch),
        .o_neq_branch               (ctl_unit_neq_branch),
        .o_mem_read                 (ctl_unit_mem_read),
        .o_mem_to_reg               (ctl_unit_mem_to_reg),
        .o_unit_alu_op              (ctl_unit_alu_op),
        .o_mem_write                (ctl_unit_mem_write),
        .o_alu_src                  (ctl_unit_alu_src),
        .o_register_write           (ctl_unit_register_write),
        .o_extension_mode           (ctl_unit_extend_mode),
        .o_datamem_size             (ctl_unit_dato_mem_size),
        .o_data_load_size           (ctl_unit_data_load_size),
        .o_zero_extend              (ctl_unit_zero_extend),
        .o_halt                     (ctl_unit_halt)
    );

    //Unidad de Riegos
    UnitRisk#(
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


    mux_unit_risk #(
    )
    u_ID_Mux_Unidad_Riesgos
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
        .i_datomem_size             (ctl_unit_dato_mem_size),
        .i_data_load_size           (ctl_unit_data_load_size),
        .i_zero_extend              (ctl_unit_zero_extend),
        .i_lui                      (ctl_unit_lui),
        .i_jalR                     (ctl_unit_jal_R),
        .i_halt                     (ctl_unit_halt),
        .o_reg_dst_rd               (mux_ctl_unit_register_rd),
        .o_jump                     (mux_ctl_unit_jump),
        .o_jal                      (mux_ctl_unit_jal),
        .o_branch                   (mux_ctl_unit_branch),
        .o_neq_branch               (mux_ctl_unit_neq_branch),
        .o_mem_read                 (mux_ctl_unit_mem_read),
        .o_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .o_unit_alu_op              (mux_ctl_unit_alu_op),
        .o_mem_write                (mux_ctl_unit_mem_write),
        .o_alu_src                  (mux_ctl_unit_alu_src),
        .o_register_write           (mux_ctl_unit_register_write),
        .o_extension_mode           (mux_ctl_unit_extend_mode),
        .o_datamem_size             (mux_ctl_unit_dato_mem_size),
        .o_data_load_size           (mux_ctl_unit_data_load_size),
        .o_zero_extend              (mux_ctl_unit_zero_extend),
        .o_lui                      (mux_ctl_unit_lui),
        .o_jalR                     (mux_ctl_unit_jal_R),
        .o_halt                     (mux_ctl_unit_halt)
    );  


    //LATCH ID/EX
    IDEX#(
        .BITS_SIZE                  (BITS_SIZE),
        .BITS_REGS                  (BITS_REGS)
    )
    module_IDEX
    (
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
         //ControlMEM
        .i_branch                   (mux_ctl_unit_branch),
        .i_neq_branch               (mux_ctl_unit_neq_branch),
        .i_mem_write                (mux_ctl_unit_mem_write),
        .i_mem_read                 (mux_ctl_unit_mem_read),
        .i_datomem_size             (mux_ctl_unit_dato_mem_size),
        //ControlWB
        .i_mem_to_reg               (mux_ctl_unit_mem_to_reg),
        .i_reg_write                (mux_ctl_unit_register_write),
        .i_data_load_size           (mux_ctl_unit_data_load_size),
        .i_zero_extend              (mux_ctl_unit_zero_extend),
        .i_lui                      (mux_ctl_unit_lui),
        .i_jalR                     (mux_ctl_unit_jal_R),
        .i_halt                     (mux_ctl_unit_halt),

        //Modules
        .i_data_rs                 (ID_data_rs),
        .i_register_data_2         (ID_data_rt),
        .i_extension               (ID_intruct_ext),
        .i_rs                      (ID_register_rs),
        .i_rt                      (ID_register_rt),
        .i_rd                      (ID_register_rd),
        //.i_DJump                   (ID_JUMP_o),

        .o_pc4                     (IDEX_PC4),
        .o_pc8                     (IDEX_PC8),
        .o_instruction             (IDEX_instruction),
        .o_register_1              (IDEX_register1),
        .o_register_2              (IDEX_register2),
        .o_extension               (IDEX_extension),
        .o_rs                      (IDEX_RS),
        .o_rt                      (IDEX_RT),   
        .o_rd                      (IDEX_RD),
        //.o_DJump                   (IDEX_DJump),
        //ControlEX
        .o_jump                    (IDEX_ctl_jump),
        .o_jalR                    (IDEX_ctl_JALR),
        .o_jal                     (IDEX_ctl_jal),
        .o_alu_src                 (IDEX_ctl_alu_src),
        .o_unit_alu_op             (IDEX_ctl_unit_alu_op),
        .o_register_rd_dst         (IDEX_ctl_register_rd),
        //ControlMEM
        .o_branch                  (IDEX_ctl_branch),
        .o_neq_branch              (IDEX_ctl_neq_branch),
        .o_mem_write               (IDEX_ctl_mem_write),
        .o_mem_read                (IDEX_ctl_mem_read),
        .o_datamem_size            (IDEX_ctl_datomem_size),
        //ControlWB
        .o_mem_to_reg              (IDEX_ctl_mem_to_reg),
        .o_register_write          (IDEX_ctl_register_write),
        .o_data_load_size          (IDEX_ctL_dataload_size),
        .o_zero_extend             (IDEX_ctl_zero_extend),
        .o_lui                     (IDEX_ctl_lui),
        .o_halt                    (IDEX_ctl_halt)
    );

    //ETAPA EX

//ETAPA EX
    EX#(
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
        .i_ctl_select_reg_rd        (IDEX_ctl_register_rd),
        .i_rt                       (IDEX_RT),
        .i_rd                       (IDEX_RD),
        .o_alu_zero                 (EX_flag_alu_zero),
        .o_alu_result               (EX_alu_result),
        .o_sum_pc_branch            (EX_sum_pc_branch),
        .o_data_register_A          (EX_alu_register_A),
        .o_mux_register_rd          (EX_mux_register_rd)
    );


    //Control ALU
    Control_ALU#(
        .BITS_ALU                (BITS_ALU ),
        .BITS_ALU_CTL            (BITS_ALU_CTL),
        .ALU_OP                  (BITS_OP)
    )
    module_ctl_alu
    (
        .i_funct                 (EX_ctl_alu_instruction),
        .i_opcode                (EX_ctl_alu_opcode),
        .i_unit_alu_op           (IDEX_ctl_unit_alu_op),
        .o_alu_op                (EX_ctl_alu_op),
        .o_shamt                 (EX_flag_shamt)
    );

   
    // UNIDAD DE CORTOCIRCUITO

    //CORTOCIRCUITO
    UnitCortocircuito#(
        .BITS_REGS                (BITS_REGS),
        .BITS_CORTOCIRCUITO       (BITS_CORTOCIRCUITO)
    )
    Unidad_de_Cortocicuito
    (
        .i_EXMEM_register_write (EXMEM_ctl_register_write), 
        .i_EXMEM_rdrt           (EXMEM_register_dst),       
        .i_MEMWB_reg_write      (MEMWB_ctl_register_write),    
        .i_MEMWB_rdrt           (MEMWB_register_dst),      
        .i_rs                   (IDEX_RS),                  
        .i_rt                   (IDEX_RT),                 
        .o_mux_A                (corto_register_A),         
        .o_mux_B                (corto_register_B)        
    );


    
    EXMEM #(
        .BITS_SIZE              (BITS_SIZE),
        .BITS_REGS              (BITS_REGS)
    )
    module_EXMEM
    (
        //General
        .i_clk                  (i_clk),
        .i_reset                (i_reset),
        .i_step                 (i_ctl_clk_wiz),
        .i_flush_latch          (id_unit_risk_latch),
        .i_pc4                  (IDEX_PC4),
        .i_pc8                  (IDEX_PC8),
        .i_pc_branch            (EX_sum_pc_branch),
        .i_idex_instruction     (IDEX_instruction),
        .i_flag_alu_zero        (EX_flag_alu_zero),
        .i_alu_result           (EX_alu_result),
        .i_idex_register2       (IDEX_register2),
        .i_register_dst         (EX_mux_register_rd),
        .i_idex_extension       (IDEX_extension),

        //ControlMEM
        .i_jal                  (IDEX_ctl_jal),
        .i_branch               (IDEX_ctl_branch),
        .i_neq_branch           (IDEX_ctl_neq_branch),
        .i_mem_write            (IDEX_ctl_mem_write),
        .i_mem_read             (IDEX_ctl_mem_read),
        .i_datamem_size         (IDEX_ctl_datomem_size),
        
        //ControlWB
        .i_mem_to_reg           (IDEX_ctl_mem_to_reg),
        .i_reg_write            (IDEX_ctl_register_write),
        .i_data_load_size       (IDEX_ctL_dataload_size),
        .i_zero_extend          (IDEX_ctl_zero_extend),
        .i_lui                  (IDEX_ctl_lui),
        .i_halt                 (IDEX_ctl_halt),

        .o_pc4                  (EXMEM_PC4),
        .o_pc8                  (EXMEM_PC8),
        .o_pc_branch            (EXMEM_PC_Branch),
        .o_instruction          (EXMEM_Instr),
        .o_zero                 (EXMEM_zero_alu),
        .o_alu                  (EXMEM_alu),
        .o_register_2           (EXMEM_register2),
        .o_register_rd_dst      (EXMEM_register_dst),
        .o_extension            (EXMEM_extension),

        //ControlMEM
        .o_jal                  (EXMEM_ctl_jal),
        .o_branch               (EXMEM_ctl_branch),
        .o_neq_branch           (EXMEM_ctl_neq_branch),
        .o_mem_write            (EXMEM_ctl_mem_write),
        .o_mem_read             (EXMEM_ctl_mem_read),
        .o_datamem_size         (EXMEM_ctl_datomem_size),

        //ControlWB
        .o_mem_to_reg           (EXMEM_ctl_mem_to_reg),
        .o_register_write       (EXMEM_ctl_register_write),
        .o_data_load_size       (EXMEM_ctL_dataload_size),
        .o_zero_extend          (EXMEM_ctl_zero_extend),
        .o_lui                  (EXMEM_ctl_lui),
        .o_halt                 (EXMEM_ctl_halt)
    );

    /*and_branch #(
    )
    module_and_branch
    (
        .i_branch       (EXMEM_ctl_branch),
        .i_neq_branch   (EXMEM_ctl_neq_branch),
        .i_zero         (EXMEM_zero_alu),
        .o_pc_source    (MEM_PC_src_o)
    );*/
    
    //ETAPA MEM
    MEM #(
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
        .i_ctl_datomem_size     (EXMEM_ctl_datomem_size),
        .o_mem_dato             (MEM_dato_mem),
        .o_mem_dato_debug       (MEM_dato_mem_Debug)
    );

 //LATCH MEMWB
    MEMWB #(
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
        .i_data_load_size   (EXMEM_ctL_dataload_size),
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
        .o_data_load_size   (MEMWB_ctL_dataload_size),
        .o_zero_extend      (MEMWB_ctl_zero_extend),
        .o_lui              (MEMWB_ctl_lui),
        .o_jal              (MEMWB_ctl_jal),
        .o_halt             (MEMWB_ctl_halt)
    );


     WB #(
        .BITS_SIZE          (BITS_SIZE),       
        .HW_BITS            (HW_BITS),
        .BYTE_BITS_SIZE     (BYTE_SIZE),
        .BITS_REGS          (BITS_REGS),      
        .BITS_EXTENSION     (BITS_EXTENSION)
    )
    module_WB   
    (
        .i_memwb_lui            (MEMWB_ctl_lui),
        .i_memwb_extension      (MEMWB_extension),
        .i_memwb_dato_mem       (MEMWB_dato_mem),
        .i_ctl_dataload_size    (MEMWB_ctL_dataload_size),
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