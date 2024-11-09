`timescale 1ns / 1ps


module filter_load
    #(
        parameter   BITS_SIZE       =   32,
        parameter   HW_BITS         =   16,
        parameter   BYTE_BITS_SIZE  =   8,
        parameter   BITS_EXTENSION  =   2
    )
    (
        input   wire    [BITS_SIZE-1:0]         i_dato_mem,
        input   wire    [BITS_EXTENSION-1:0]    i_size_filterL,
        input   wire                            i_zero,             //es un flag para decir si es Unsigned
        output  wire    [BITS_SIZE-1:0]         o_dato_filterL
    );
    
    reg [BITS_SIZE-1:0] reg_dato_filterL;

    
    always @(*)
    begin : Tamano
            case(i_size_filterL)
                2'b00:       
                        reg_dato_filterL   <=   i_dato_mem;
                2'b01 :
                    case(i_zero)
                        1'b0:   reg_dato_filterL   <=   {{HW_BITS+BYTE_BITS_SIZE{i_dato_mem[BYTE_BITS_SIZE-1]}}, i_dato_mem[BYTE_BITS_SIZE-1:0]};
                        1'b1:   reg_dato_filterL   <=   i_dato_mem & 32'b00000000_00000000_00000000_11111111;      
                    endcase
                2'b10    :
                    case(i_zero)
                        1'b0:   reg_dato_filterL   <=   {{HW_BITS{i_dato_mem[HW_BITS-1]}}, i_dato_mem[HW_BITS-1:0]};
                        1'b1:   reg_dato_filterL   <=   i_dato_mem & 32'b00000000_00000000_11111111_11111111; 
                    endcase
                default:   
                        reg_dato_filterL   <=   -1;
            endcase
    end
    

    assign o_dato_filterL=  reg_dato_filterL;


endmodule
