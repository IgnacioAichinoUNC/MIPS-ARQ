`timescale 1ns / 1ps

module EX
    #(
        parameter   BITS_SIZE           = 32,
        parameter   BITS_OP           = 6,
        parameter   BITS_REGS            = 5,
        parameter   BITS_CORTOCIRCUITO   = 3
    )
    (
        input  wire      [BITS_SIZE-1:0]           i_id_extension,
        input  wire      [BITS_SIZE-1:0]           i_id_pc4,
        input  wire      [BITS_REGS-1:0]           i_alu_shamt,
        input  wire                                i_flag_shamt,
        input  wire      [BITS_OP-1:0]             i_alu_op,
        input  wire      [BITS_CORTOCIRCUITO-1:0]  i_corto_register_A,  
        input  wire      [BITS_SIZE-1 :0]          i_register1,
        input  wire      [BITS_SIZE-1:0]           i_exmem_register, 
        input  wire      [BITS_SIZE-1:0]           i_wb_data_write,
        input  wire                                i_idex_ctl_alu_src,
        input  wire      [BITS_CORTOCIRCUITO-1:0]  i_corto_register_B,
        input  wire      [BITS_SIZE-1:0]           i_register2,
        input  wire                                i_select_register,
        input  wire      [BITS_REGS-1:0]           i_rt,
        input  wire      [BITS_REGS-1:0]           i_rd,
        output wire      [BITS_SIZE-1:0]           o_sum_pc_branch,
        output wire      [BITS_SIZE-1:0]           o_data_register_A,
        output wire                                o_alu_zero,
        output wire      [BITS_SIZE-1:0]           o_alu_result,
        output wire      [BITS_REGS-1:0]           o_mux_register_rd 
        
    );


        wire             [BITS_SIZE-1:0]           mux_data_a;
        wire             [BITS_SIZE-1:0]           o_mux_data_b;

        assign            o_data_register_A  =          mux_data_a;
   


    sum_branch
    #
    (
        .BITS_SIZE              (BITS_SIZE)
    )
    sum_branch
    (
        .i_extension_data            (i_id_extension),
        .i_sum_pc4                   (i_id_pc4),
        .o_sum_pc_branch             (o_sum_pc_branch)
    );


    alu
    #(
        .BITS_SIZE                    (BITS_SIZE),
        .BITS_REGS                    (BITS_REGS),
        .BITS_OP                      (BITS_OP )
    )
    alu
    (
        .i_data_1                     (mux_data_a),
        .i_data_2                     (o_mux_data_b),
        .i_alu_shamt                  (i_alu_shamt),
        .i_flag_shamt                 (i_flag_shamt),
        .i_alu_op                     (i_alu_op),
        .o_alu_zero                   (o_alu_zero),
        .o_result                     (o_alu_result)
    );

    mux_alu_shamt
    #(
        .BITS_SIZE                         (BITS_SIZE),
        .BITS_CORTOCIRCUITO                (BITS_CORTOCIRCUITO)
    )
    mux_alu_shamt
    (
        .i_corto_register_A             (i_corto_register_A),
        .i_idex_register1               (i_register1),
        .i_exmem_register               (i_exmem_register),
        .i_memwb_register               (i_wb_data_write),
        .o_mux_alu_a                    (mux_data_a)
    );
    
    mux_alu
    #(
        .BITS_SIZE                      (BITS_SIZE),
        .BITS_CORTOCIRCUITO              (BITS_CORTOCIRCUITO)
    )
    mux_alu
    (
        .i_alu_src                  (i_idex_ctl_alu_src),
        .i_corto_register_B      (i_corto_register_B),
        .i_idex_register2                 (i_register2),
        .i_extension_data           (i_id_extension),
        .i_exmem_register               (i_exmem_register),
        .i_memwb_register          (i_wb_data_write),
        .o_mux_alu_b               (o_mux_data_b)
    );
    
    
    mux_register_rtrd
    #(
        .BITS_REGS                      (BITS_REGS)
    )
    mux_register_rtrd
    (
        .i_reg_dst_rd           (i_select_register ),
        .i_rt                   (i_rt),
        .i_rd                   (i_rd),
        .o_mux_register_rd      (o_mux_register_rd)
    );

   
    

endmodule