`timescale 1ns / 1ps

module ID
    #(
        parameter   BITS_SIZE       = 32,
        parameter   BITS_JUMP       = 26,
        //parameter   REGS            = 5,
        parameter   BITS_REGS        = 5,
        //parameter   TAM_REG         = 32,
        parameter   REG_SIZE        = 32,
        parameter   BITS_INMEDIATE  = 16,
        parameter   BITS_EXTENSION  = 2
        
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire                            i_mem_wb_regwrite,
        input   wire     [BITS_REGS-1:0]             i_dir_rs,
        input   wire     [BITS_REGS-1:0]             i_dir_rt,
        input   wire     [BITS_REGS-1:0]             i_tx_dir_debug,
        input   wire     [BITS_REGS-1:0]             i_wb_dir_rd,
        input   wire     [BITS_SIZE-1:0]            i_wb_write,
        input   wire     [BITS_JUMP-1:0]        i_IFID_JUMP, //los bits 0 a 26 de la instrucción que entrega el IF (dirección a la que voy a saltar)
        input   wire     [BITS_SIZE-1:0]            i_IDEX_PC4,
        input   wire     [BITS_INMEDIATE-1:0]           i_id_inmediate,
        input   wire     [BITS_EXTENSION-1:0]           i_rctrl_extensionmode,
        output  wire     [BITS_SIZE-1:0]            o_data_rs,
        output  wire     [BITS_SIZE-1:0]            o_data_rt,
        output  wire     [BITS_SIZE-1:0]            o_data_tx_debug,
        output  wire     [BITS_SIZE-1:0]            o_ID_JUMP,  
        output  wire     [BITS_SIZE-1:0]            o_extensionresult
        
    );

  
    PC_Jump
    #(
        .BITS_SIZE      (BITS_SIZE),
        .BITS_JUMP      (BITS_JUMP)
    )
    u_PC_Jump
    (
        .i_IFID_JUMP     (i_IFID_JUMP), 
        .i_IDEX_PC4      (i_IDEX_PC4),
        .o_ID_JUMP       (o_ID_JUMP)
    );
    
    
    RegisterFile
    #(
        .BITS_REGS       (BITS_REGS),
        .BITS_SIZE       (BITS_SIZE),
        .REG_SIZE        (REG_SIZE)
    )
    u_Register_File
    (
        .i_clk               (i_clk),
        .i_reset             (i_reset),
        .i_step              (i_step),
        .i_RegWrite          (i_mem_wb_regwrite),
        .i_dir_rs            (i_dir_rs),
        .i_dir_rt            (i_dir_rt),
        .i_RegDebug          (i_tx_dir_debug),
        .i_RD                (i_wb_dir_rd),
        .i_DatoEscritura     (i_wb_write),
        .o_data_rs           (o_data_rs),
        .o_data_rt           (o_data_rt),
        .o_RegDebug          (o_data_tx_debug)

    );
  
  
    SignExtend
    #(
        .BITS_INMEDIATE           (BITS_INMEDIATE),
        .BITS_EXTEND              (BITS_INMEDIATE),
        .BITS_OUT                 (BITS_SIZE)
    )
    u_Sign_Extend
    (
        .i_id_inmediate         (i_id_inmediate), //16 bits de la instrucción recibida por etapa IF
        .i_extension_mode       (i_rctrl_extensionmode), //
        .o_extensionresult      (o_extensionresult) //resultado de la extensión de signo
    );

endmodule