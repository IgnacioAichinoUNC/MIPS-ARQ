`timescale 1ns / 1ps

module MEM
    #(
        parameter   BITS_SIZE           = 32,
        parameter   BITS_EXTENSION      = 2,
        parameter   SIZE_MEM_DATA       = 10       
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire    [BITS_SIZE-1:0]         i_exmem_alu,
        input   wire    [BITS_SIZE-1:0]         i_addr_mem_debug,
        input   wire                            i_exmem_mem_read,
        input   wire                            i_exmem_mem_write,
        input   wire    [BITS_SIZE-1:0]         i_exmem_mem_register2,
        input   wire    [1:0]                   i_ctl_datomem_size,
        output  wire    [BITS_SIZE-1:0]         o_mem_dato,
        output  wire    [BITS_SIZE-1:0]         o_mem_dato_debug
    );

    
    memory_data
    #(
        .BITS_SIZE      (BITS_SIZE),
        .SIZE_MEM_DATA  (SIZE_MEM_DATA)
    )
    module_mem_data
    (
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_step             (i_step),
        .i_alu_address      (i_exmem_alu),
        .i_debug_address    (i_addr_mem_debug),
        .i_data_register    (i_exmem_mem_register2),
        .i_flag_mem_read    (i_exmem_mem_read),
        .i_flag_mem_write   (i_exmem_mem_write),
        .i_ctl_data_size_mem(i_ctl_datomem_size),
        .o_data_read        (o_mem_dato),
        .o_debug_data       (o_mem_dato_debug)
    );
  

endmodule