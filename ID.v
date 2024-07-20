`timescale 1ns / 1ps

module ID
    #(
        parameter   BITS_SIZE       = 32,
        parameter   BITS_JUMP       = 26,
        parameter   BITS_REGS        = 5,
        parameter   REG_SIZE        = 32,
        parameter   BITS_INMEDIATE  = 16,
        parameter   BITS_EXTENSION  = 2

    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire                            i_wb_reg_write,
        input   wire     [BITS_REGS-1:0]        i_addr_rs,
        input   wire     [BITS_REGS-1:0]        i_addr_rt,
        input   wire     [BITS_REGS-1:0]        i_wb_addr_rd,
        input   wire     [BITS_REGS-1:0]        i_tx_adrr_reg_unitdebug,  //direccion de registro para unitdebug
        input   wire     [BITS_SIZE-1:0]        i_wb_data,

        input   wire     [BITS_JUMP-1:0]        i_IFID_JUMP, //los bits 0 a 26 de la instrucción que entrega el IF (dirección a la que voy a saltar)
        input   wire     [BITS_SIZE-1:0]        i_IDEX_PC4,

        input   wire     [BITS_INMEDIATE-1:0]   i_id_inmediate,
        input   wire     [BITS_EXTENSION-1:0]   i_rctrl_extensionmode,

        output  wire     [BITS_SIZE-1:0]        o_rs,
        output  wire     [BITS_SIZE-1:0]        o_rt,
        output  wire     [BITS_SIZE-1:0]        o_data_tx_debug,

        output  wire     [BITS_SIZE-1:0]        o_ID_JUMP,  

        
        output  wire     [BITS_SIZE-1:0]        o_extension_result

    );


    pc_jump
    #(
        .BITS_SIZE      (BITS_SIZE),
        .BITS_JUMP      (BITS_JUMP)
    )
    PC_Jump
    (
        .i_ifid_jump        (i_IFID_JUMP), 
        .i_idex_pc4         (i_IDEX_PC4),
        .o_ID_JUMP          (o_ID_JUMP)
    );


    BankRegisters
    #(
        .BITS_REGS       (BITS_REGS),
        .BITS_SIZE       (BITS_SIZE),
        .REG_SIZE        (REG_SIZE)
    )
    bank_registers
    (
        .i_clk               (i_clk),
        .i_reset             (i_reset),
        .i_step              (i_step),
        .i_flag_regWrite     (i_wb_reg_write),
        .i_addr_rs           (i_addr_rs),
        .i_addr_rt           (i_addr_rt),
        .i_addr_rd           (i_wb_addr_rd),
        .i_adrr_unitdebug    (i_tx_adrr_reg_unitdebug),
        .i_data_write        (i_wb_data),
        .o_rs                (o_rs),
        .o_rt                (o_rt),
        .o_reg_unitdebug     (o_data_tx_debug)

    );


    sign_extensor
    #(
        .BITS_INMEDIATE      (BITS_INMEDIATE),
        .BITS_EXTEND         (BITS_INMEDIATE),
        .BITS_OUT            (BITS_SIZE)
    )
    sign_extensor
    (
        .i_id_inmediate      (i_id_inmediate), //16 bits de la instrucción recibida por etapa IF
        .i_extension_mode    (i_rctrl_extensionmode), //
        .o_extension         (o_extension_result) //resultado de la extensión de signo
    );

endmodule