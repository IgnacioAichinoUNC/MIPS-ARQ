`timescale 1ns / 1ps

module memory_instrucc
    #(
        parameter SIZE_ADDR_PC      = 32,
        parameter TOTAL_SIZE        = 256
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire    [SIZE_ADDR_PC-1    :0]  i_pc,
        input   wire    [SIZE_ADDR_PC-1    :0]  i_instrucction_address,
        input   wire    [SIZE_ADDR_PC-1    :0]  i_instruction,
        input   wire                            i_flag_write_intruc,
        output  reg     [SIZE_ADDR_PC-1    :0]  o_instruction   
    );
    
    reg [SIZE_ADDR_PC-1  :0]  reg_memory[TOTAL_SIZE-1:0];
    integer index;
    
    initial 
    begin
        for (index = 0; index<TOTAL_SIZE; index= index + 1) begin
            reg_memory[index] = 0;
        end  
    end


    always @(posedge i_clk)
    begin
        if (i_step)begin
            o_instruction  <= reg_memory[i_pc];
        end
    end

    always @(posedge i_flag_write_intruc) begin
            reg_memory[i_instrucction_address] <= i_instruction; 
    end

endmodule
