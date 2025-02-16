`timescale 1ns / 1ps

module mux_alu_datoB
    #(
        parameter BITS_SIZE             = 32,
        parameter BITS_CORTOCIRCUITO    = 3
        
    )
    (
        input   wire                                i_alu_src,            //Indica si el dato B es el de la extension o el registro
        input   wire    [BITS_CORTOCIRCUITO-1:0]    i_corto_register_B,   //Selecciona el dato segun el corto
        input   wire    [BITS_SIZE-1:0]             i_idex_register2,   
        input   wire    [BITS_SIZE-1:0]             i_extension_data,
        input   wire    [BITS_SIZE-1:0]             i_exmem_register,      //Resultado ALU EXMEM
        input   wire    [BITS_SIZE-1:0]             i_memwb_register,     //Resultado ALU MEMWR
        output  wire    [BITS_SIZE-1:0]             o_mux_alu_b                 
    );
    
    reg [BITS_SIZE-1:0]     reg_register_alu_b;
    
    always @(*)
    begin
        if(i_alu_src)begin
                reg_register_alu_b <= i_extension_data;
            end
        else
            begin
                case(i_corto_register_B)
                    3'b001:     reg_register_alu_b  <=  i_exmem_register;
                    3'b010:     reg_register_alu_b  <=  i_memwb_register;
                    default:    reg_register_alu_b  <=  i_idex_register2;
                endcase
            end 
    end

    assign  o_mux_alu_b =   reg_register_alu_b;

endmodule
