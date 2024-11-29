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

    //Señales internas
    wire [BITS_SIZE-1:0] wire_filtered_data;
    wire [BITS_SIZE-1:0] wire_data_to_reg;
    wire [BITS_SIZE-1:0] wire_data_write;

    // Instancia del submódulo `WB_Core`
    mux_register_rd
    #(
        .BITS_SIZE      (BITS_SIZE),
        .HW_BITS        (HW_BITS),
        .BYTE_BITS_SIZE (BYTE_BITS_SIZE),
        .BITS_EXTENSION (BITS_EXTENSION),
        .BITS_REGS      (BITS_REGS)
    )
    core
    (
        .i_memwb_lui            (i_memwb_lui),
        .i_memwb_extension      (i_memwb_extension),
        .i_memwb_dato_mem       (i_memwb_dato_mem),
        .i_memwb_size_filterL   (i_memwb_size_filterL),
        .i_memwb_zero_extend    (i_memwb_zero_extend),
        .i_memwb_mem_to_reg     (i_memwb_mem_to_reg),
        .i_memwb_alu            (i_memwb_alu),
        .o_filtered_data        (wire_filtered_data),
        .o_data_to_reg          (wire_data_to_reg),
        .o_data_write           (wire_data_write)
    );

    //Salidas calculadas
    assign o_wb_data_write = i_memwb_jal ? i_memwb_pc8 : wire_data_write;
    assign o_wb_register_adrr_result = i_memwb_jal ? 5'b11111 : i_memwb_register_dst;
    assign o_wb_data_write_ex = wire_data_write;

endmodule
