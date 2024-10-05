`timescale 1ns / 1ps

module WB
    #(
        parameter   BITS_SIZE       = 32,
        parameter   HW_BITS         = 16,
        parameter   BYTE_BITS_SIZE  = 8,
        parameter   BITS_REGS       = 5,
        parameter   BITS_EXTENSION  = 2
    )
    (
        input   wire                        i_memwb_lui,
        input   wire    [BITS_SIZE-1:0]     i_memwb_extension,
        input   wire    [BITS_SIZE-1:0]     i_memwb_dato_mem,
        input   wire    [1:0]               i_memwb_size_filterL,
        input   wire                        i_memwb_zero_extend,
        input   wire                        i_memwb_mem_to_reg,
        input   wire    [BITS_SIZE-1:0]     i_memwb_alu,
        input   wire                        i_memwb_jal,
        input   wire    [BITS_SIZE-1:0]     i_memwb_pc8,
        input   wire    [BITS_REGS-1:0]     i_memwb_register_dst,
        output  wire    [BITS_SIZE-1:0]     o_wb_data_write_ex,
        output  wire    [BITS_SIZE-1:0]     o_wb_data_write,
        output  wire    [BITS_REGS-1:0]     o_wb_register_adrr_result
    );


    wire    [BITS_SIZE-1:0]     wire_wb_filterL;
    wire    [BITS_SIZE-1:0]     wire_wb_data_to_reg;
    wire    [BITS_SIZE-1:0]     wire_wb_data_write;


    mux_lui
    #(
        .BITS_SIZE(BITS_SIZE)
    )
    module_mux_lui
    (
        .i_lui(i_memwb_lui),
        .i_extension(i_memwb_extension),
        .i_filterL(wire_wb_filterL),
        .o_mux_memory(wire_wb_data_to_reg)
    );

    filter_load
    #(
        .BITS_SIZE(BITS_SIZE),
        .HW_BITS(HW_BITS),
        .BYTE_BITS_SIZE(BYTE_BITS_SIZE),
        .BITS_EXTENSION(BITS_EXTENSION) 
    )
    module_filter_load
    (
        .i_dato_mem(i_memwb_dato_mem),
        .i_size_filterL(i_memwb_size_filterL),
        .i_zero(i_memwb_zero_extend),
        .o_dato_filterL(wire_wb_filterL) 
    );


    mux_memory
    #(
        .BITS_SIZE(BITS_SIZE) 
    )
    module_mux_memory
    (
        .i_mem_to_reg(i_memwb_mem_to_reg),
        .i_data_to_reg(wire_wb_data_to_reg),
        .i_alu(i_memwb_alu),
        .o_to_mux_write_data(wire_wb_data_write)
    );


    mux_write_data
    #(
        .BITS_SIZE(BITS_SIZE) 
    )
    module_mux_write_data
    (
        .i_jal(i_memwb_jal),
        .i_data_write(wire_wb_data_write),
        .i_pc8(i_memwb_pc8),
        .o_data_write(o_wb_data_write) 
    );


    mux_register_rd
    #(
        .BITS_REGS(BITS_REGS)
    )
    module_mux_register_rd
    (
        .i_jal(i_memwb_jal),
        .i_register_dst(i_memwb_register_dst),
        .o_register_addr(o_wb_register_adrr_result) 
    );
    

  
    assign o_wb_data_write_ex  = wire_wb_data_write;
endmodule