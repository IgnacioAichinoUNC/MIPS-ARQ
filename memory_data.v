`timescale 1ns / 1ps

module memory_data
    #(
        parameter BITS_SIZE         = 32,
        parameter SIZE_MEM_DATA     = 16,
        parameter BITS_EXTENSION    = 2

    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire    [BITS_SIZE-1:0]     i_alu_address,
        input   wire    [BITS_SIZE-1:0]     i_debug_address,
        input   wire    [BITS_SIZE-1:0]     i_data_register,
        input   wire                        i_flag_mem_read,
        input   wire                        i_flag_mem_write,
        input   wire    [BITS_EXTENSION-1:0]i_ctl_data_size_mem,
        output  reg     [BITS_SIZE-1:0]     o_data_read,
        output  reg     [BITS_SIZE-1:0]     o_debug_data
    );
    
    reg  [BITS_SIZE-1:0]    reg_dato_filtered;
    reg  [BITS_SIZE-1:0]    reg_memory[SIZE_MEM_DATA-1:0];

    integer i;
    initial 
    begin
        for (i = 0; i < SIZE_MEM_DATA; i = i + 1) begin
                reg_memory[i] <= i;
        end
        o_debug_data  <=  0;
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


    //Filtro size de dato a mem
    always @(*) begin
            //00: complete word
            //01: SB -> para un byte
            //10: SH -> para media palabra
        case(i_ctl_data_size_mem)
            2'b00:       
                    reg_dato_filtered   <=   i_data_register; //memory[base+offset] = rt 
            2'b01:        
                    reg_dato_filtered   <=   i_data_register & 32'b00000000_00000000_00000000_11111111;   // para instrucciones sb
            2'b10:
                    reg_dato_filtered   <=   i_data_register & 32'b00000000_00000000_11111111_11111111;   // para instrucciones sh
            default :   
                    reg_dato_filtered   <=   0;
        endcase
    end


    always @(negedge i_clk)
    begin
        if(i_flag_mem_write & i_step) begin
            reg_memory[i_alu_address]  <=  reg_dato_filtered;
        end
    end
    
    always @(i_debug_address)
    begin
        o_debug_data  <=  reg_memory[i_debug_address];
    end


endmodule