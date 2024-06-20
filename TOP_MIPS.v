`timescale 1ns / 1ps

//module MIPS
module TOP_MIPS
    #(
        parameter   BITS_SIZE           = 32,
        parameter   SIZE_MEM_INSTRUC    = 256,
        parameter   SIZE_INSTRUC_DEBUG  = 8,
        parameter   BITS_JUMP           = 26,
        parameter   BITS_REGS            = 5,
        parameter   REG_SIZE            = 32,
        parameter   BITS_INMEDIATE      = 16,
        parameter   BITS_EXTENSION      = 2,
        parameter   BITS_UNIT_CONTROL   = 6,
        parameter   BITS_ALU_CONTROL    = 2
        
    )
    (   
        input   wire                                i_clk,
        input   wire                                i_reset,
        input   wire                                i_ctl_clk_wiz,
        input   wire     [BITS_REGS-1:0]            i_select_reg_dir,
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
    wire                            id_risk_Mux;
    wire                            id_risk_latch_flush;

    // Unidad Control
    wire     [BITS_UNIT_CONTROL-1:0]        ID_InstrControl;
    wire     [BITS_UNIT_CONTROL-1:0]        ID_InstrSpecial;
    wire                            ctl_unidad_regWrite;
    wire                            ctl_unidad_mem_to_reg;
    wire                            ctl_unidad_branch;
    wire     [BITS_ALU_CONTROL-1:0]        ctl_unidad_alu_op;
    wire     [BITS_EXTENSION-1:0]           ctl_unidad_extend_mode;
    wire     [BITS_EXTENSION-1:0]           ctl_unidad_size_filter;
    wire     [BITS_EXTENSION-1:0]           ctl_unidad_size_filterL;
    wire                            ctl_unidad_Nbranch;
    wire                            ctl_unidad_jump;
    wire                            ctl_unidad_jal;
    wire                            ctl_unidad_reg_rd;
    wire                            ctl_unidad_alu_src;
    wire                            ctl_unidad_mem_read;
    wire                            ctl_unidad_mem_write;
    wire                            ctl_unidad_zero_extend;
    wire                            ctl_unidad_lui;
    wire                            ctl_unidad_jalR;
    wire                            ctl_unidad_halt;

    //Mux Unidad Riesgos
    wire                            Rctl_unidad_regWrite;
    wire                            Rctl_unidad_mem_to_reg;
    wire                            Rctl_unidad_branch;
    wire     [BITS_ALU_CONTROL-1:0]        Rctl_unidad_alu_op;
    wire     [BITS_EXTENSION-1:0]           Rctl_unidad_extend_mode;
    wire                            Rctl_unidad_Nbranch;
    wire                            Rctl_unidad_jump;
    wire                            Rctl_unidad_jal;
    wire                            Rctl_unidad_reg_rd;
    wire                            Rctl_unidad_alu_src;
    wire                            Rctl_unidad_mem_read;
    wire                            Rctl_unidad_mem_write;
    wire     [BITS_EXTENSION-1:0]           Rctl_unidad_size_filter;
    wire     [BITS_EXTENSION-1:0]           Rctl_unidad_size_filterL;
    wire                            Rctl_unidad_zero_extend ;
    wire                            Rctl_unidad_lui;
    wire                            Rctl_unidad_jalR;
    wire                            Rctl_unidad_halt;
    
    //Sumador PC Jump 
    wire     [BITS_JUMP-1:0]        ID_JUMP_in;
    wire     [BITS_SIZE-1:0]        ID_JUMP_out;

    //Regs
    wire     [BITS_REGS-1:0]            ID_Reg_rs_i;
    wire     [BITS_REGS-1:0]            ID_Reg_rd_i;
    wire     [BITS_REGS-1:0]            ID_Reg_rt_i;
    wire     [BITS_SIZE-1:0]           ID_data_read1;
    wire     [BITS_SIZE-1:0]           ID_data_read2;
    wire     [BITS_SIZE-1:0]           ID_Reg_Debug;

    // Extensor de signo
    wire     [INBITS-1:0]          ID_Instr16_i;
    wire     [BITS_SIZE-1:0]       ID_InstrExt;

// ---------IDEX----------------------------------------------- //Implementar en modulo, solo sirve ahora en debug  

    //   IDEX
    wire    [BITS_SIZE-1:0]            IDEX_PC4;
    wire    [BITS_SIZE-1:0]            IDEX_PC8;
    wire    [BITS_SIZE-1:0]            IDEX_Reg1;
    wire    [BITS_SIZE-1:0]            IDEX_Reg2;
    wire    [BITS_REGS-1:0]            IDEX_Rs;
    wire    [BITS_REGS-1:0]            IDEX_Rt;
    wire    [BITS_REGS-1:0]            IDEX_Rd;
    wire    [BITS_SIZE-1:0]            IDEX_DJump;
    wire    [BITS_SIZE-1:0]            IDEX_Extension;
    wire    [BITS_SIZE-1:0]            IDEX_Instr;

    //ID/EX/CONTROL
    wire                            IDEX_ctl_alu_src;
    wire                            IDEX_ctl_jump;
    wire                            IDEX_ctl_JALR;
    wire                            IDEX_ctl_unidad_jal;
    wire    [1:0]                   IDEX_ctl_unidad_alu_op;
    wire                            IDEX_ctl_unidad_reg_rd;
    wire                            IDEX_ctl_unidad_branch;
    wire                            IDEX_ctl_unidad_Nbranch;
    wire                            IDEX_ctl_unidad_mem_write;
    wire                            IDEX_ctl_unidad_mem_read;
    wire                            IDEX_ctl_unidad_mem_to_reg;
    wire                            IDEX_ctl_unidad_regWrite;
    wire                            IDEX_ctl_unidad_lui;
    wire                            IDEX_ctl_unidad_halt;
    wire    [1:0]                   IDEX_ctl_unidad_size_filter;
    wire    [1:0]                   IDEX_ctl_unidad_size_filterL;
    wire                            IDEX_ctl_unidad_zero_extend;


//--------EX/MEM---------------------------
    wire    [BITS_SIZE-1:0]         EXMEM_PC_Branch;
//MEM
    wire                            MEM_PC_src_o; 



//--------EX/MEM---------------------------
//MuxShamt
    wire     [BITS_SIZE-1:0]        EX_alu_regA;

//    MEM 

//   MEM_WB
    wire                            MEM_WB_RegWrite;

    //MultiplexorMemoria 
    wire    [REGS-1:0]              WB_RegistroDestino_o;
    //MultiplexorEscribirDato
    wire    [NBITS-1:0]             WB_EscribirDato_o;

    //Extensor
    assign ID_Instr16_i        =   IFID_Instr     [BITS_INMEDIATE-1:0];


    // ID
    assign ID_InstrControl     =    IFID_Instr     [BITS_SIZE-1:BITS_SIZE-BITS_UNIT_CONTROL]; //[31:26] sería el identificador de la instrucción (op)
    assign ID_InstrSpecial     =    IFID_Instr     [BITS_UNIT_CONTROL-1:0] ; //[5:0]
    assign ID_Jump_in          =    IFID_Instr     [BITS_JUMP-1:0] ; //En caso de ser un salto, la dirección se encuentra en los bits 0 a 26.

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

    //ETAPA ID  


    ID
    #(
        .BITS_SIZE           (BITS_SIZE),
        .BITS_JUMP           (BITS_JUMP),
        .BITS_REGS           (BITS_REGS),
        .REG_SIZE            (REG_SIZE),
        .BITS_INMEDIATE      (BITS_INMEDIATE),
        .BITS_EXTENSION      (BITS_EXTENSION)
    )
    u_ID
    (
        .i_clk                 (i_clk),
        .i_reset               (i_reset),
        .i_step                (i_ctl_clk_wiz),
        .i_mem_wb_regwrite     (MEM_WB_RegWrite),
        .i_dir_rs              (ID_Reg_rs_i),
        .i_dir_rt              (ID_Reg_rt_i),
        .i_tx_dir_debug        (i_select_reg_dir),
        .i_wb_dir_rd           (WB_RegistroDestino_o),
        .i_wb_write            (WB_EscribirDato_o),
        .i_IFID_JUMP          (ID_JUMP_in), //los bits 0 a 26 de la instrucción que entrega el IF (dirección a la que voy a saltar)
        .i_id_expc4            (IDEX_PC4),
        .i_id_inmediate        (ID_Instr16_i),
        .i_rctrl_extensionmode (ctl_unidad_extend_mode),
        .o_data_rs             (ID_data_read1),
        .o_data_rt             (ID_data_read2),
        .o_data_tx_debug       (ID_Reg_Debug),
        .o_JUMP_ID             (ID_JUMP_out),
        .o_extensionresult     (ID_InstrExt) 
    );
  
    // UNIDAD DE CONTROL

    UnitControl
    #(
        .BITS_SIZE                      (BITS_UNIT_CONTROL)
    )
    u_Unit_Control
    (
        .i_Instruction              (ID_InstrControl     ),
        .i_Special                  (ID_InstrSpecial     ),
        .o_RegDst                   (ctl_unidad_reg_rd         ),
        .o_Jump                     (ctl_unidad_jump           ),
        .o_JAL                      (ctl_unidad_jal            ),
        .o_Branch                   (ctl_unidad_branch         ),
        .o_NBranch                  (ctl_unidad_Nbranch        ),
        .o_MemRead                  (ctl_unidad_mem_read        ),
        .o_MemToReg                 (ctl_unidad_mem_to_reg),
        .o_ALUOp                    (ctl_unidad_alu_op          ),
        .o_MemWrite                 (ctl_unidad_mem_write       ),
        .o_ALUSrc                   (ctl_unidad_alu_src         ),
        .o_RegWrite                 (ctl_unidad_regWrite       ),
        .o_ExtensionMode            (ctl_unidad_extend_mode  ),
        .o_TamanoFiltro             (ctl_unidad_size_filter   ),
        .o_TamanoFiltroL            (ctl_unidad_size_filterL  ),
        .o_ZeroExtend               (ctl_unidad_zero_extend     ),
        .o_LUI                      (ctl_unidad_lui            ),
        .o_JALR                     (ctl_unidad_jalR           ),
        .o_HALT                     (ctl_unidad_halt           )
    );

    // UNIDAD DE RIESGOS
    UnitRisk
    #(
        .BITS_REGS                      (BITS_REGS)
    )
    u_Unit_Risk
    (
        .i_EXMEM_Flush             (MEM_PC_src_o),
        .i_IDEX_MemRead            (IDEX_ctl_unidad_mem_read),
        .i_EXMEM_MemRead           (EXMEM_MemRead),
        .i_JALR                     (ctl_unidad_jalR),
        .i_HALT                     (ctl_unidad_halt),
        .i_IDEX_Rt                 (IDEX_Rt ),
        .i_EXMEM_Rt                (EXMEM_RegistroDestino),
        .i_IFID_Rs                 (ID_Reg_rs_i),
        .i_IFID_Rt                 (ID_Reg_rt_i),
        .o_Mux_Risk                 (id_risk_Mux),
        .o_pc_Write                 (if_risk_pc_write),
        .o_IFID_Write              (if_id_risk_Write),
        .o_Latch_Flush              (id_risk_latch_flush)
    );


    // MUX UNIDAD DE RIESGOS

    mux_unit_risk
    #(
    )
    u_mux_unit_risk
    (
        .i_Risk                     (id_risk_Mux         ),
        .i_RegDst                   (ctl_unidad_reg_rd        ),
        .i_Jump                     (ctl_unidad_jump          ),
        .i_JAL                      (ctl_unidad_jal           ),
        .i_Branch                   (ctl_unidad_branch        ),
        .i_NBranch                  (ctl_unidad_Nbranch       ),
        .i_MemRead                  (ctl_unidad_mem_read       ),
        .i_MemToReg                 (ctl_unidad_mem_to_reg      ),
        .i_ALUOp                    (ctl_unidad_alu_op         ),
        .i_MemWrite                 (ctl_unidad_mem_write      ),
        .i_ALUSrc                   (ctl_unidad_alu_src        ),
        .i_RegWrite                 (ctl_unidad_regWrite      ),
        .i_extension_mode            (ctl_unidad_extend_mode ),
        .i_TamanoFiltro             (ctl_unidad_size_filter  ),
        .i_TamanoFiltroL            (ctl_unidad_size_filterL ),
        .i_ZeroExtend               (ctl_unidad_zero_extend    ),
        .i_LUI                      (ctl_unidad_lui           ),
        .i_JALR                     (ctl_unidad_jalR          ),
        .i_HALT                     (ctl_unidad_halt          ),
        .o_RegDst                   (Rctl_unidad_reg_rd        ),
        .o_Jump                     (Rctl_unidad_jump          ),
        .o_JAL                      (Rctl_unidad_jal           ),
        .o_Branch                   (Rctl_unidad_branch        ),
        .o_NBranch                  (Rctl_unidad_Nbranch       ),
        .o_MemRead                  (Rctl_unidad_mem_read       ),
        .o_MemToReg                 (Rctl_unidad_mem_to_reg      ),
        .o_ALUOp                    (Rctl_unidad_alu_op         ),
        .o_MemWrite                 (Rctl_unidad_mem_write      ),
        .o_ALUSrc                   (Rctl_unidad_alu_src        ),
        .o_RegWrite                 (Rctl_unidad_regWrite      ),
        .o_ExtensionMode            (Rctl_unidad_extend_mode ),
        .o_TamanoFiltro             (Rctl_unidad_size_filter  ),
        .o_TamanoFiltroL            (Rctl_unidad_size_filterL ),
        .o_ZeroExtend               (Rctl_unidad_zero_extend    ),
        .o_LUI                      (Rctl_unidad_lui           ),
        .o_JALR                     (Rctl_unidad_jalR          ),
        .o_HALT                     (Rctl_unidad_halt          )
    );  


    // ETAPA ID/EX

    IDEX
    #(
        .BITS_SIZE                      (BITS_SIZE          ),
        .BITS_REGS                     (BITS_REGS           )
    )
    u_ID_EX
    (
        //General
        .i_clk                      (i_clk                      ),
        .i_reset                    (i_reset                    ),
        .i_step                     (i_control_clk_wiz),
        .i_Flush                    (id_risk_latch_flush         ),
        .i_pc4                      (IFID_PC4                ),
        .i_pc8                      (IFID_PC8                ),
        .i_Instruction              (IFID_Instr              ),

        //ControlEX
        .i_Jump                     (Rctl_unidad_jump               ),
        .i_JAL                      (Rctl_unidad_jal                ),
        .i_ALUSrc                   (Rctl_unidad_alu_src             ),

        .i_ALUOp                    (Rctl_unidad_alu_op              ),
        .i_RegDst                   (Rctl_unidad_reg_rd             ),
        //ControlM
        .i_Branch                   (Rctl_unidad_branch             ),
        .i_NBranch                  (Rctl_unidad_Nbranch            ),
        .i_MemWrite                 (Rctl_unidad_mem_write           ),
        .i_MemRead                  (Rctl_unidad_mem_read            ),
        .i_TamanoFiltro             (Rctl_unidad_size_filter       ),
        //ControlWB
        .i_MemToReg                 (Rctl_unidad_mem_to_reg           ),
        .i_RegWrite                 (Rctl_unidad_regWrite           ),
        .i_TamanoFiltroL            (Rctl_unidad_size_filterL      ),
        .i_ZeroExtend               (Rctl_unidad_zero_extend         ),
        .i_LUI                      (Rctl_unidad_lui                ),
        .i_JALR                     (Rctl_unidad_jalR               ),
        .i_HALT                     (Rctl_unidad_halt               ),

        //Modules
        .i_Reg1                     (ID_data_read1         ),
        .i_Reg2                     (ID_data_read2         ),
        .i_extension                (ID_InstrExt           ),
        .i_rs                       (ID_Reg_rs_i             ),
        .i_rt                       (ID_Reg_rt_i             ),
        .i_Rd                       (ID_Reg_rd_i             ),
        .i_DJump                    (ID_Jump_o               ),

        .o_pc4                      (IDEX_PC4          ),
        .o_pc8                      (IDEX_PC8          ),
        .o_instruction              (IDEX_Instr        ),
        .o_Registro1                (IDEX_Reg1    ),
        .o_Registro2                (IDEX_Reg2    ),
        .o_Extension                (IDEX_Extension    ),
        .o_Rs                       (IDEX_Rs           ),
        .o_Rt                       (IDEX_Rt           ),
        .o_Rd                       (IDEX_Rd           ),
        .o_DJump                    (IDEX_DJump        ),

        //ControlEX
        .o_Jump                     (IDEX_ctl_unidad_jump         ),
        .o_JALR                     (IDEX_ctl_unidad_jalR         ),
        .o_JAL                      (IDEX_ctl_unidad_jal          ),
        .o_ALUSrc                   (IDEX_ctl_unidad_alu_src       ),
        .o_ALUOp                    (IDEX_ctl_unidad_alu_op        ),
        .o_RegDst                   (IDEX_ctl_unidad_reg_rd       ),
        //ControlM
        .o_Branch                   (IDEX_ctl_unidad_branch       ),
        .o_NBranch                  (IDEX_ctl_unidad_Nbranch      ),
        .o_MemWrite                 (IDEX_ctl_unidad_mem_write     ),
        .o_MemRead                  (IDEX_ctl_unidad_mem_read      ),
        .o_TamanoFiltro             (IDEX_ctl_unidad_size_filter ),
        //ControlWB
        .o_MemToReg                 (IDEX_ctl_unidad_mem_to_reg     ),
        .o_RegWrite                 (IDEX_ctl_unidad_regWrite),
        .o_TamanoFiltroL            (IDEX_ctl_unidad_size_filterL),
        .o_ZeroExtend               (IDEX_ctl_unidad_zero_extend   ),
        .o_LUI                      (IDEX_ctl_unidad_lui          ),
        .o_HALT                     (IDEX_ctl_unidad_halt         )
    );


endmodule