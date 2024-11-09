`timescale 1ns / 1ps
module mux_unit_risk
    (
     // Unidad de Riesgos
    input   wire            i_risk,
    // Unidad de Control
    input   wire            i_reg_dst_rd,
    input   wire            i_jump,
    input   wire            i_jal,
    input   wire            i_branch,
    input   wire            i_neq_branch,
    input   wire            i_mem_read,
    input   wire            i_mem_to_reg,
    input   wire    [1:0]   i_unit_alu_op,
    input   wire            i_mem_write,
    input   wire            i_alu_src,
    input   wire            i_reg_write,
    input   wire    [1:0]   i_extension_mode,
    input   wire    [1:0]   i_size_filter,
    input   wire    [1:0]   i_size_filterL,
    input   wire            i_zero_extend,
    input   wire            i_lui,
    input   wire            i_jalR,
    input   wire            i_halt,

    output  wire            o_reg_dst_rd,
    output  wire            o_jump,
    output  wire            o_jal,
    output  wire            o_branch,
    output  wire            o_neq_branch,
    output  wire            o_mem_read,
    output  wire            o_mem_to_reg,
    output  wire    [1:0]   o_unit_alu_op,
    output  wire            o_mem_write,
    output  wire            o_alu_src,
    output  wire            o_register_write,
    output  wire    [1:0]   o_extension_mode,
    output  wire    [1:0]   o_size_filter,
    output  wire    [1:0]   o_size_filterL,
    output  wire            o_zero_extend,
    output  wire            o_lui,
    output  wire            o_jalR,
    output  wire            o_halt
    );

        reg           reg_dst_rd;
        reg           reg_jump;
        reg           reg_jal;
        reg           reg_branch;
        reg           reg_neq_branch;
        reg           reg_mem_read;    
        reg           reg_mem_to_reg;
        reg    [1:0]  reg_unit_alu_op;
        reg           reg_mem_write;
        reg           reg_alu_src;
        reg           reg_register_write;
        reg    [1:0]  reg_extension_mode;
        reg    [1:0]  reg_size_filter;
        reg    [1:0]  reg_size_filterL;
        reg           reg_zero_extend;
        reg           reg_lui;
        reg           reg_jalR;


        always @(*)
        begin
            if(i_risk)
                begin
                    reg_dst_rd          <=  1'b0;
                    reg_jump            <=  1'b0;
                    reg_jal             <=  1'b0;
                    reg_branch          <=  1'b0;
                    reg_neq_branch      <=  1'b0;
                    reg_mem_read        <=  1'b0;
                    reg_mem_to_reg      <=  1'b0;
                    reg_unit_alu_op     <=  1'b0;
                    reg_mem_write       <=  1'b0;
                    reg_alu_src         <=  1'b0;
                    reg_register_write  <=  1'b0;
                    reg_extension_mode  <=  1'b0;
                    reg_size_filter     <=  1'b0;
                    reg_size_filterL    <=  1'b0;
                    reg_zero_extend     <=  1'b0;
                    reg_lui             <=  1'b0;
                    reg_jalR            <=  1'b0;
                end
            else
                begin
                    reg_dst_rd          <=  i_reg_dst_rd;
                    reg_jump            <=  i_jump;
                    reg_jal             <=  i_jal;
                    reg_branch          <=  i_branch;
                    reg_neq_branch      <=  i_neq_branch;
                    reg_mem_read        <=  i_mem_read;
                    reg_mem_to_reg      <=  i_mem_to_reg;
                    reg_unit_alu_op     <=  i_unit_alu_op;
                    reg_mem_write       <=  i_mem_write;
                    reg_alu_src         <=  i_alu_src;
                    reg_register_write  <=  i_reg_write;
                    reg_extension_mode  <=  i_extension_mode;
                    reg_size_filter     <=  i_size_filter;
                    reg_size_filterL    <=  i_size_filterL;
                    reg_zero_extend     <=  i_zero_extend;
                    reg_lui             <=  i_lui;
                    reg_jalR            <=  i_jalR;
                end
          end

        assign o_reg_dst_rd     = reg_dst_rd;
        assign o_jump           = reg_jump;
        assign o_jal            = reg_jal;
        assign o_branch         = reg_branch;
        assign o_neq_branch     = reg_neq_branch;
        assign o_mem_read       = reg_mem_read;
        assign o_mem_to_reg     = reg_mem_to_reg;
        assign o_unit_alu_op    = reg_unit_alu_op;
        assign o_mem_write      = reg_mem_write;
        assign o_alu_src        = reg_alu_src;
        assign o_register_write = reg_register_write;
        assign o_extension_mode = reg_extension_mode;
        assign o_size_filter    = reg_size_filter;
        assign o_size_filterL   = reg_size_filterL;
        assign o_zero_extend    = reg_zero_extend;
        assign o_lui            = reg_lui;
        assign o_jalR           = reg_jalR;
        assign o_halt           = i_halt;
endmodule