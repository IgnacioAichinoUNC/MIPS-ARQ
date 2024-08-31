`timescale 1ns / 1ps

//00: complete word
//01: SB -> para un byte
//10: SH -> para media palabra

module filter_mem
    #(
        parameter   BITS_SIZE           =   32,
        parameter   BITS_EXTENSION          =   2   
    )
    (
        input   wire    [BITS_SIZE-1:0]         i_dato_rt,      // REG[rt]
        input   wire    [BITS_EXTENSION-1:0]    i_ctl_select,   // selector dependiendo la instrucción SB / SH / OTRA
        output  wire    [BITS_SIZE-1:0]         o_dato_to_write         
    );
    
    reg [BITS_SIZE-1    :0] reg_dato;

    
    always @(*)
    begin : selector
            case(i_ctl_select)
                2'b00:       
                        reg_dato   <=   i_dato_rt; // rt sin modifiaciones: memory[base+offset] <- rt 
                2'b01:        
                        reg_dato   <=   i_dato_rt & 32'b00000000_00000000_00000000_11111111;    // para instrucciones sb:  memory[base+offset] <- rt
                2'b10:
                        reg_dato   <=   i_dato_rt & 32'b00000000_00000000_11111111_11111111;    // para instrucciones sh:  memory[base+offset] <- rt
                default :   
                        reg_dato   <=   -1;
            endcase
    end

    assign o_dato_to_write =    reg_dato;


endmodule