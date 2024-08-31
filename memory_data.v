`timescale 1ns / 1ps

module memory_data
    #(
        parameter BITS_SIZE         = 32,
        parameter SIZE_MEM_DATA     = 16
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire    [BITS_SIZE-1:0]         i_alu_address,
        input   wire    [BITS_SIZE-1:0]         i_debug_address,
        input   wire    [BITS_SIZE-1:0]         i_data_register,
        input   wire                            i_flag_mem_read,
        input   wire                            i_flag_mem_write,
        output  reg     [BITS_SIZE-1:0]         o_data_read,
        output  reg     [BITS_SIZE-1:0]         o_debug_data
    );
    
    reg  [BITS_SIZE-1:0]    reg_memory[SIZE_MEM_DATA-1:0];

    integer i;
    
    always @(negedge i_clk)
    begin
        if(i_flag_mem_write & i_step) begin
            reg_memory[i_alu_address]  <=  i_data_reg;
        end
    end

    initial 
    begin
        for (i = 0; i < SIZE_MEM_DATA; i = i + 1) begin
                reg_memory[i] <= i;
        end
        o_debug_data  <=  0;
    end
    
    always @(i_debug_address)
    begin
        o_debug_data  <=  reg_memory[i_debug_address];
    end


    //Default siempre
    always @(*)
    begin
        if (i_flag_mem_read & i_step) begin
            o_data_read    <=  reg_memory[i_alu_address];
        end else begin
            o_data_read    <=  0;
        end
    end


endmodule