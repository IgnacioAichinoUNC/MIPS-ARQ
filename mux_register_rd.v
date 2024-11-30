`timescale 1ns / 1ps

module mux_register_rd
    #(
        parameter   BITS_SIZE       = 32,
        parameter   HW_BITS         = 16,
        parameter   BYTE_BITS_SIZE  = 8,
        parameter   BITS_EXTENSION  = 2,
        parameter   BITS_REGS       = 5
    )
    (
        input   wire                        i_memwb_lui,
        input   wire    [BITS_SIZE-1:0]     i_memwb_extension,
        input   wire    [BITS_SIZE-1:0]     i_memwb_dato_mem,
        input   wire    [1:0]               i_ctl_dataload_size,
        input   wire                        i_memwb_zero_extend,
        input   wire                        i_memwb_mem_to_reg,
        input   wire    [BITS_SIZE-1:0]     i_memwb_alu,
        output  wire    [BITS_SIZE-1:0]     o_data_write
    );

    reg [BITS_SIZE-1:0] reg_filtered_data;
    reg [BITS_SIZE-1:0] reg_data_to_reg;
    reg [BITS_SIZE-1:0] reg_data_write;

    //Filtro load
    always @(*) begin
        case (i_ctl_dataload_size)
            2'b00: reg_filtered_data = i_memwb_dato_mem;
            2'b01: reg_filtered_data = i_memwb_zero_extend ? 
                                       (i_memwb_dato_mem & 32'hFF) : {{HW_BITS+BYTE_BITS_SIZE{i_memwb_dato_mem[BYTE_BITS_SIZE-1]}}, i_memwb_dato_mem[BYTE_BITS_SIZE-1:0]};
            2'b10: reg_filtered_data = i_memwb_zero_extend ? 
                                       (i_memwb_dato_mem & 32'hFFFF) : {{HW_BITS{i_memwb_dato_mem[HW_BITS-1]}}, i_memwb_dato_mem[HW_BITS-1:0]};
            default: reg_filtered_data = -1;
        endcase
    end

    //Select Data
    always @(*) begin
        reg_data_to_reg = i_memwb_lui ? i_memwb_extension : reg_filtered_data;
    end

    //Select Dato to write
    always @(*) begin
        reg_data_write = i_memwb_mem_to_reg ? reg_data_to_reg : i_memwb_alu;
    end

    assign o_data_write = reg_data_write;

endmodule
